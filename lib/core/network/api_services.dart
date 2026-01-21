import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/helper/custom_snack_bar.dart';
import '../../core/network/app_urls.dart';
import '../../db/shared_pref_manager.dart';
import '../helper/logger_helper.dart';
import 'api_keys.dart';

class ApiServices extends GetxService {
  final Duration _timeout = const Duration(seconds: 60);

  /// Common GET method
  Future<Map<String, dynamic>?> callGet(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool showErrorToast = true,
  }) async {
    final uri = Uri.parse(
      "${AppUrls.apiBaseUrl}$endpoint",
    ).replace(queryParameters: queryParams);

    print("authnticationtoken : " + SharedPrefManager().token.toString());
    return _safeCall(() async {
      final response = await http
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);

      print("getapiresponse : " + response.body);
      return _parseResponse(response, showErrorToast: showErrorToast);
    });
  }

  /// Common POST method
  Future<Map<String, dynamic>?> callPost(
    String endpoint, {
    required Map<String, dynamic> data,
    bool isUserRequired = false,
    bool isFormData = false,
    bool showErrorToast = true,
  }) async {
    if (isUserRequired) {
      final userId = {
        ApiKeys.userId: (SharedPrefManager().user?.id ?? "").toString(),
      };
      data.addAll(userId);
    }

    final uri = Uri.parse("${AppUrls.apiBaseUrl}$endpoint");

    logApiMessage("Request --> ${uri.toString()}");

    return _safeCall(() async {
      if (isFormData) {
        final request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_defaultHeaders());

        data.forEach((key, value) {
          if (value is String) {
            request.fields[key] = value;
          }
        });

        logApiMessage("Request --> ${uri.toString()}");

        for (final entry in data.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            final fileStream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              entry.key,
              fileStream,
              length,
              filename: file.path.split("/").last,
            );
            request.files.add(multipartFile);
          }
        }

        final streamedResponse = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);
        return _parseResponse(response, showErrorToast: showErrorToast);
      } else {
        final response = await http
            .post(uri, headers: _defaultHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        return _parseResponse(response, showErrorToast: showErrorToast);
      }
    });
  }

  Future<Map<String, dynamic>?> callDelete(
    String endpoint, {
    Map<String, dynamic>? data,
    bool isUserRequired = false,
  }) async {
    Map<String, dynamic> bodyData = data ?? {};

    if (isUserRequired) {
      final userId = {
        ApiKeys.userId: (SharedPrefManager().user?.id ?? "").toString(),
      };
      bodyData.addAll(userId);
    }

    final uri = Uri.parse("${AppUrls.apiBaseUrl}$endpoint");

    logApiMessage("DELETE --> ${uri.toString()}");
    if (bodyData.isNotEmpty) {
      logApiMessage("DELETE BODY --> ${jsonEncode(bodyData)}");
    }

    return _safeCall(() async {
      http.Response response;

      if (bodyData.isNotEmpty) {
        // DELETE with body
        response = await http.Request(
          "DELETE",
          uri,
        ).sendWithBody(_defaultHeaders(), jsonEncode(bodyData));
      } else {
        response = await http
            .delete(uri, headers: _defaultHeaders())
            .timeout(_timeout);
      }

      return _parseResponse(response);
    });
  }

  /// Default headers
  Map<String, String> _defaultHeaders() => {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    "Authorization":
        "Bearer ${SharedPrefManager().token ?? AppUrls.defaultApiKey}",
  };

  /// Safe API call wrapper
  Future<Map<String, dynamic>?> _safeCall(
    Future<Map<String, dynamic>?> Function() call,
  ) async {
    try {
      return await call();
    } on SocketException catch (e) {
      _handleError("Network error: $e");
    } on TimeoutException catch (e) {
      _handleError("Request timed out: $e");
    } catch (e, stackTrace) {
      printMessage("Unexpected error: $e\n$stackTrace");
      CustomSnackBar.showError(message: "An unexpected error occurred.");
    }
    return null;
  }

  /// Parse response body safely
  Map<String, dynamic>? _parseResponse(http.Response response, {bool showErrorToast = true}) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      logApiMessage(" Response --> $body  ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body is Map<String, dynamic> ? body : {"data": body};
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        if (showErrorToast) {
          _handleError(body['message']);
        } else {
          printMessage("HTTP ERROR: ${body['message']}");
        }
        return body;
      } else if (response.statusCode == 422) {
        return body;
      } else {
        if (showErrorToast && response.statusCode < 500) {
          _handleError(
            "Server returned ${response.statusCode}: ${response.reasonPhrase}",
          );
        } else {
          printMessage("HTTP ERROR: Server returned ${response.statusCode}: ${response.reasonPhrase}");
        }
      }
    } catch (e) {
      if (showErrorToast) _handleError("Invalid JSON: $e");
    }
    return null;
  }

  /// Error handler
  void _handleError(String message) {
    printMessage("HTTP ERROR: $message");
    CustomSnackBar.showError(message: message);
  }

  /// Logging helpers
  void logApiError(String message) => printMessage("⚠️ $message");

  void logApiMessage(String message) => printMessage("📡 $message");
}

extension DeleteRequestWithBody on http.Request {
  Future<http.Response> sendWithBody(
    Map<String, String> headers,
    String body,
  ) async {
    this.headers.addAll(headers);
    this.body = body;

    final streamedResponse = await this.send();
    return http.Response.fromStream(streamedResponse);
  }
}
