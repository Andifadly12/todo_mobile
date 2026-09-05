import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class ApiClient {
  ApiClient({required this.baseUrl, required this.client});
  final String baseUrl;
  final http.Client client;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await client
          .post(
            Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/$path'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
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
        final message = data['message'] ?? data['error'];
        throw ApiException(
          message is String && message.isNotEmpty
              ? message
              : 'Permintaan gagal (${response.statusCode}). Silakan coba lagi.',
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
