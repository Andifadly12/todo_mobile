import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final int? statusCode;
  final String message;
}

class ApiClient {
  ApiClient({required this.baseUrl, required this.client});
  final String baseUrl;
  final http.Client client;

  String? accessToken;
  String? refreshToken;
  Future<void>? _refreshing;
  int _sessionVersion = 0;

  void setSession(String access, String refresh) {
    _sessionVersion++;
    accessToken = access;
    refreshToken = refresh;
  }

  void clearSession() {
    _sessionVersion++;
    accessToken = null;
    refreshToken = null;
  }

  Future<void> logout({bool all = false}) async {
    if (all) {
      await post('auth/logout-all', {});
    } else if (refreshToken != null) {
      await post('auth/logout', {'refreshToken': refreshToken});
    }
    clearSession();
  }

  Future<void> _refresh() async {
    final current = _refreshing;
    if (current != null) return current;
    final future = _rotate();
    _refreshing = future;
    try {
      await future;
    } finally {
      if (identical(_refreshing, future)) _refreshing = null;
    }
  }

  Future<void> _rotate() async {
    final version = _sessionVersion;
    try {
      final data = await post('auth/refresh', {'refreshToken': refreshToken});
      if (version != _sessionVersion) {
        throw const ApiException('Sesi telah berubah. Silakan login kembali.');
      }
      final access = data['accessToken'], refresh = data['refreshToken'];
      if (access is! String ||
          access.isEmpty ||
          refresh is! String ||
          refresh.isEmpty) {
        throw const ApiException('Respons pembaruan sesi tidak valid.');
      }
      setSession(access, refresh);
    } on ApiException catch (e) {
      if (version == _sessionVersion &&
          (e.statusCode == 401 || e.statusCode == 403)) {
        clearSession();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      request('POST', path, body);

  Future<Map<String, dynamic>> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final data = await _request(method, path, body);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Format respons server tidak sesuai.');
    }
    return data;
  }

  Future<List<dynamic>> getList(String path) async {
    final data = await _request('GET', path);
    if (data is! List) {
      throw const ApiException('Format daftar server tidak sesuai.');
    }
    return data;
  }

  Future<dynamic> _request(
    String method,
    String path, [
    Map<String, dynamic>? body,
    bool retried = false,
  ]) async {
    final sentToken = accessToken;
    try {
      final req = http.Request(
        method,
        Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/$path'),
      );
      req.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });
      if (body != null) req.body = jsonEncode(body);
      final response = await (() async => http.Response.fromStream(
        await client.send(req),
      ))().timeout(const Duration(seconds: 15));
      if (response.statusCode == 401 &&
          !path.startsWith('auth/') &&
          !retried &&
          refreshToken != null) {
        if (sentToken == accessToken) await _refresh();
        if (accessToken == null) {
          throw const ApiException(
            'Sesi berakhir. Silakan login kembali.',
            statusCode: 401,
          );
        }
        return await _request(method, path, body, true);
      }
      dynamic data = <String, dynamic>{};
      if (response.body.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> || decoded is List) {
            data = decoded;
          } else if (response.statusCode < 300) {
            throw const ApiException('Format respons server tidak sesuai.');
          }
        } on FormatException {
          if (response.statusCode < 300) {
            throw const ApiException('Format respons server tidak sesuai.');
          }
        }
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          (data is Map && data['success'] == false)) {
        final rawMessage = data is Map
            ? data['message'] ?? data['error']
            : null;
        final message = rawMessage is List ? rawMessage.join('\n') : rawMessage;
        throw ApiException(
          message is String && message.isNotEmpty
              ? message
              : 'Permintaan gagal (${response.statusCode}). Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
        'Server terlalu lama merespons. Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      );
    }
  }

  void close() => client.close();
}
