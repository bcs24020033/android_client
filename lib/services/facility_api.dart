import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/facility.dart';

class FacilityApiException implements Exception {
  const FacilityApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FacilityApi {
  FacilityApi({String? baseUrl})
      : baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:3000',
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final String baseUrl;

  Future<List<Facility>> findNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
  }) async {
    final uri = Uri.parse('$baseUrl/api/facilities').replace(
      queryParameters: {
        'lat': latitude.toStringAsFixed(6),
        'lng': longitude.toStringAsFixed(6),
        'radiusKm': radiusKm.toString(),
      },
    );
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);

    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
            const Duration(seconds: 12),
          );
      final responseText = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseText);
      if (decoded is! Map<String, dynamic>) {
        throw const FacilityApiException('The API returned an invalid response.');
      }
      if (response.statusCode != 200) {
        final message = decoded['error'];
        throw FacilityApiException(
          message is String ? message : 'Facilities could not be loaded.',
        );
      }

      final values = decoded['facilities'];
      if (values is! List) {
        throw const FacilityApiException('The API returned an invalid facility list.');
      }
      return values
          .map((value) => Facility.fromJson(
                Map<String, dynamic>.from(value as Map),
              ))
          .toList(growable: false);
    } on FacilityApiException {
      rethrow;
    } on SocketException {
      throw const FacilityApiException(
        'Could not reach the API. Start the API server and try again.',
      );
    } on TimeoutException {
      throw const FacilityApiException(
        'The API took too long to respond. Please try again.',
      );
    } on FormatException {
      throw const FacilityApiException(
        'The API returned an invalid response. Please try again.',
      );
    } finally {
      client.close(force: true);
    }
  }
}
