import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ReportApiException implements Exception {
  const ReportApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WasteReportApi {
  WasteReportApi({required this.accessToken, String? baseUrl})
      : baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:3000',
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final String accessToken;
  final String baseUrl;

  Future<void> submit({
    required String category,
    required String description,
    required String imageBase64,
    required String imageMimeType,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);

    try {
      final request = await client.postUrl(Uri.parse('$baseUrl/api/reports'));
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      request.add(
        utf8.encode(
          jsonEncode({
            'category': category,
            'description': description.trim(),
            'imageBase64': imageBase64,
            'imageMimeType': imageMimeType,
          }),
        ),
      );

      final response = await request.close().timeout(
            const Duration(seconds: 30),
          );
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseText);
      if (decoded is! Map<String, dynamic>) {
        throw const ReportApiException('The API returned an unreadable response.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded['error'];
        throw ReportApiException(
          message is String ? message : 'The report could not be submitted.',
        );
      }
    } on ReportApiException {
      rethrow;
    } on SocketException {
      throw const ReportApiException(
        'Could not reach the API. Connect to the internet and try again.',
      );
    } on TimeoutException {
      throw const ReportApiException(
        'The upload took too long. Check your connection and try again.',
      );
    } on FormatException {
      throw const ReportApiException('The API returned an invalid response.');
    } finally {
      client.close(force: true);
    }
  }
}
