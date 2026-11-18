import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/auth_session.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({String? baseUrl})
      : baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:3000',
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final String baseUrl;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return _send('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _send('/api/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }

  Future<AuthSession> _send(String path, Map<String, String> payload) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);

    try {
      final request = await client.postUrl(Uri.parse('$baseUrl$path'));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close().timeout(
            const Duration(seconds: 12),
          );
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseText);
      if (decoded is! Map<String, dynamic>) {
        throw const AuthApiException('The API returned an unreadable response.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded['error'];
        throw AuthApiException(
          message is String ? message : 'Sign-in could not be completed.',
        );
      }

      return AuthSession.fromJson(decoded);
    } on AuthApiException {
      rethrow;
    } on SocketException {
      throw const AuthApiException(
        'Could not reach the API. Start the API server and try again.',
      );
    } on TimeoutException {
      throw const AuthApiException(
        'The API took too long to respond. Please try again.',
      );
    } on FormatException {
      throw const AuthApiException(
        'The API returned an invalid response. Please try again.',
      );
    } finally {
      client.close(force: true);
    }
  }
}
