import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/inspection.dart';

/// Uploads inspection records to the web backend and marks each failure as
/// retryable or not.
class SyncException implements Exception {
  const SyncException(this.message, {this.retryable = true});
  final String message;

  /// 4xx validation errors won't succeed on retry; 5xx and network errors will.
  final bool retryable;

  @override
  String toString() => message;
}

abstract interface class InspectionApi {
  /// Uploads one record and returns the server-side id.
  Future<int> upload(Inspection inspection);
}

/// Talks to the web application. Defaults to JSONPlaceholder, which accepts
/// POSTs and echoes an id, so the sync flow can be demoed end to end.
class HttpInspectionApi implements InspectionApi {
  HttpInspectionApi({
    http.Client? client,
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  @override
  Future<int> upload(Inspection inspection) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/posts'),
            headers: {
              'Content-Type': 'application/json',
              'Idempotency-Key': inspection.id,
            },
            body: jsonEncode(inspection.toApiJson()),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw SyncException('Network error: $e');
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['id'] as int;
    }
    throw SyncException(
      'Server rejected record (${res.statusCode})',
      retryable: res.statusCode >= 500 || res.statusCode == 429,
    );
  }
}
