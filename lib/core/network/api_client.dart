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

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      request('POST', path, body);

  Future<Map<String, dynamic>> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
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
      Map<String, dynamic> data = {};
      if (response.body.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
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
          data['success'] == false) {
        final rawMessage = data['message'] ?? data['error'];
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
