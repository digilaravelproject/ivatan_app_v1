import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

import '../../core/helper/custom_snack_bar.dart';
import '../../core/network/app_urls.dart';
import '../../db/shared_pref_manager.dart';
import '../helper/logger_helper.dart';
import 'api_keys.dart';

class ApiServices extends GetxService {
  final Duration _timeout = const Duration(seconds: 300);

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
      _logRequest(
        method: "GET",
        uri: uri,
        headers: _defaultHeaders(),
        body: queryParams,
      );

      final response = await http
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);

      _logResponse(response);


      print("getapiresponse : " + response.body);
      return _parseResponse(response, showErrorToast: showErrorToast);
    });
  }

  /// Common GET method for downloading binary data
  Future<http.Response?> callDownload(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool showErrorToast = true,
  }) async {
    final uri = Uri.parse(
      "${AppUrls.apiBaseUrl}$endpoint",
    ).replace(queryParameters: queryParams);

    return _safeCallBytes(() async {
      final response = await http
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        _parseResponse(response, showErrorToast: showErrorToast);
        return null;
      }
    });
  }

  Future<http.Response?> _safeCallBytes(
    Future<http.Response?> Function() call,
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

  /// Common POST method with progress tracking (using Dio)
  Future<dio.Response?> callPostWithProgress(
    String endpoint, {
    required Map<String, dynamic> data,
    void Function(int, int)? onSendProgress,
  }) async {
    final dioClient = dio.Dio();
    dioClient.options.baseUrl = AppUrls.apiBaseUrl;
    dioClient.options.headers = _defaultHeaders();
    dioClient.options.connectTimeout = _timeout;
    dioClient.options.receiveTimeout = const Duration(minutes: 30);
    dioClient.options.sendTimeout = const Duration(minutes: 30);

    final formData = dio.FormData();

    // Flatten data for multipart
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        formData.files.add(MapEntry(
          key,
          dio.MultipartFile.fromFileSync(
            value.path,
            filename: value.path.split("/").last,
          ),
        ));
      } else if (value is List && value.isNotEmpty && value.first is File) {
        for (var file in value) {
          if (file is File) {
            formData.files.add(MapEntry(
              key, // Usually "media[]"
              dio.MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split("/").last,
              ),
            ));
          }
        }
      } else if (value != null) {
        if (value is Map || value is List) {
           _flattenDioMultipartData(key, value, formData.fields);
        } else {
           formData.fields.add(MapEntry(key, value.toString()));
        }
      }
    }

    try {
      print("API REQUEST [$endpoint]: ${formData.fields.map((e) => "${e.key}: ${e.value}")}");
      print("API FILES [$endpoint]: ${formData.files.map((e) => "${e.key}: ${e.value.filename}")}");

      final response = await dioClient.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      print("API RESPONSE [$endpoint]: ${response.statusCode}");
      return response;
    } on dio.DioException catch (e) {
      print("DIO ERROR [$endpoint]: ${e.message}");
      print("DIO STATUS: ${e.response?.statusCode}");
      print("DIO DATA: ${e.response?.data}");
      
      logApiError("DIO POST ERROR: ${e.message}");
      if (e.response != null) {
        _handleError(e.response?.data['message'] ?? e.message);
      } else {
        _handleError(e.message ?? "Unknown network error");
      }
      return e.response;
    } catch (e) {
      print("GENERAL ERROR [$endpoint]: $e");
      return null;
    }
  }

  void _flattenDioMultipartData(String prefix, dynamic value, List<MapEntry<String, String>> fields) {
    if (value is Map) {
      value.forEach((key, val) {
        _flattenDioMultipartData("$prefix[$key]", val, fields);
      });
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        _flattenDioMultipartData("$prefix[$i]", value[i], fields);
      }
    } else if (value != null) {
      fields.add(MapEntry(prefix, value.toString()));
    }
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
        request.headers.addAll(_multipartHeaders());

        data.forEach((key, value) {
          if (value is File) return; // files handled separately below
          if (value == null) return; // skip null values
          
          if (value is Map || value is List) {
            _flattenMultipartData(key, value, request.fields);
          } else if (value is bool) {
            request.fields[key] = value ? '1' : '0';
          } else if (value is num) {
            request.fields[key] = value.toString();
          } else {
            request.fields[key] = value.toString();
          }
        });

        logApiMessage("Request --> ${uri.toString()}");
        _logRequest(
          method: "POST (Multipart)",
          uri: uri,
          headers: request.headers,
          body: data,
        );

        for (final entry in data.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            final multipartFile = await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.path.split("/").last,
            );
            request.files.add(multipartFile);
          } else if (entry.value is List && (entry.value as List).isNotEmpty && (entry.value as List).first is File) {
            final files = entry.value as List;
            for (var file in files) {
              if (file is File) {
                final multipartFile = await http.MultipartFile.fromPath(
                  entry.key,
                  file.path,
                  filename: file.path.split("/").last,
                );
                request.files.add(multipartFile);
              }
            }
          }
        }


        final streamedResponse = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);
        _logResponse(response);
        return _parseResponse(response, showErrorToast: showErrorToast);
      } else {
        _logRequest(
          method: "POST",
          uri: uri,
          headers: _defaultHeaders(),
          body: data,
        );
        final response = await http
            .post(uri, headers: _defaultHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        _logResponse(response);
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


    _logRequest(
      method: "DELETE",
      uri: uri,
      headers: _defaultHeaders(),
      body: bodyData,
    );

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

        _logResponse(response);

      }

      return _parseResponse(response);
    });
  }



  /// Common PUT method
  Future<Map<String, dynamic>?> callPut(
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
    logApiMessage("PUT Request --> ${uri.toString()}");

    return _safeCall(() async {
      if (isFormData) {
        // Multipart PUT request
        final request = http.MultipartRequest("PUT", uri);
        request.headers.addAll(_multipartHeaders());

        data.forEach((key, value) {
          if (value is File) return; // files handled separately below
          if (value == null) return;  // skip null values
          if (value is bool) {
            request.fields[key] = value ? '1' : '0';
          } else if (value is num) {
            request.fields[key] = value.toString();
          } else if (value is String) {
            request.fields[key] = value;
          }
        });

        for (final entry in data.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            final multipartFile = await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.path.split("/").last,
            );
            request.files.add(multipartFile);
          }
        }


        _logRequest(
          method: "PUT",
          uri: uri,
          headers: _defaultHeaders(),
          body: data,
        );

        final streamedResponse = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);
        _logResponse(response);
        return _parseResponse(response, showErrorToast: showErrorToast);
      } else {
        // Normal JSON PUT
        final response = await http
            .put(uri, headers: _defaultHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        return _parseResponse(response, showErrorToast: showErrorToast);
      }
    });
  }

  /// Common PATCH method
  Future<Map<String, dynamic>?> callPatch(
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
    logApiMessage("PATCH Request --> ${uri.toString()}");

    return _safeCall(() async {
      if (isFormData) {
        // Multipart PATCH request
        final request = http.MultipartRequest("PATCH", uri);
        request.headers.addAll(_multipartHeaders());

        data.forEach((key, value) {
          if (value is File) return; // files handled separately below
          if (value == null) return;  // skip null values
          if (value is bool) {
            request.fields[key] = value ? '1' : '0';
          } else if (value is num) {
            request.fields[key] = value.toString();
          } else if (value is String) {
            request.fields[key] = value;
          }
        });

        for (final entry in data.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            final multipartFile = await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.path.split("/").last,
            );
            request.files.add(multipartFile);
          }
        }

        _logRequest(
          method: "PATCH",
          uri: uri,
          headers: _defaultHeaders(),
          body: data,
        );

        final streamedResponse = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);
        _logResponse(response);
        return _parseResponse(response, showErrorToast: showErrorToast);
      } else {
        // Normal JSON PATCH
        _logRequest(
          method: "PATCH",
          uri: uri,
          headers: _defaultHeaders(),
          body: data,
        );
        final response = await http
            .patch(uri, headers: _defaultHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        _logResponse(response);
        return _parseResponse(response, showErrorToast: showErrorToast);
      }
    });
  }


  /// Default headers
  Map<String, String> _defaultHeaders() => {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    "Authorization":
        "Bearer ${SharedPrefManager().token ?? AppUrls.defaultApiKey}",
  };

  /// Headers for multipart requests (without content-type)
  Map<String, String> _multipartHeaders() => {
    HttpHeaders.acceptHeader: "application/json",
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
      } else if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 404) {
        if (showErrorToast) {
          _handleError(body['message'] ?? response.reasonPhrase);
        } else {
          printMessage("HTTP ERROR: ${body['message'] ?? response.reasonPhrase}");
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





  void _logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    dynamic body,
  }) {
    printMessage("""
================= 📤 API REQUEST =================
METHOD: $method
URL: ${uri.toString()}
HEADERS: ${headers ?? {}}
BODY: ${body ?? "No Body"}
==================================================
""");
  }




  void _logResponse(http.Response response) {
    printMessage("""
================= 📥 API RESPONSE =================
STATUS CODE: ${response.statusCode}
REASON: ${response.reasonPhrase}
BODY: ${response.body}
===================================================
""");
  }




  /// Helper to flatten nested Maps and Lists for multipart requests
  void _flattenMultipartData(String prefix, dynamic value, Map<String, String> fields) {
    if (value is Map) {
      value.forEach((key, val) {
        _flattenMultipartData("$prefix[$key]", val, fields);
      });
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        _flattenMultipartData("$prefix[$i]", value[i], fields);
      }
    } else if (value != null) {
      if (value is bool) {
        fields[prefix] = value ? '1' : '0';
      } else {
        fields[prefix] = value.toString();
      }
    }
  }
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



