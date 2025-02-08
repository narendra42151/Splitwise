import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:splitwise/data/URLS.dart';

import 'package:splitwise/data/AppException.dart';
import 'package:splitwise/data/Network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(BASEURL + url))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      print("No Internet connection");
      throw InternetException();
    } on TimeoutException {
      print("Request timed out");

      throw RequestTimeOutException();
    } on HttpException {
      print("HTTP exception occurred");
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      print("Invalid JSON format");
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> postApi(dynamic data, String url) async {
    dynamic responseJson;
    try {
      final response = await http
          .post(Uri.parse(BASEURL + url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      print("No Internet connection");
      throw InternetException();
    } on TimeoutException {
      print("Request timed out");

      throw RequestTimeOutException();
    } on HttpException {
      print("HTTP exception occurred");
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      print("Invalid JSON format");
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> postApiWithHeaders(
      dynamic data, String url, Map<String, String>? headers) async {
    dynamic responseJson;
    try {
      final response = await http
          .post(Uri.parse(BASEURL + url),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      print("No Internet connection");
      throw InternetException();
    } on TimeoutException {
      print("Request timed out");

      throw RequestTimeOutException();
    } on HttpException {
      print("HTTP exception occurred");
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      print("Invalid JSON format");
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> getApiWithHeaders(
      String url, Map<String, String>? headers) async {
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(BASEURL + url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      print("No Internet connection");
      throw InternetException();
    } on TimeoutException {
      print("Request timed out");

      throw RequestTimeOutException();
    } on HttpException {
      print("HTTP exception occurred");
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      print("Invalid JSON format");
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> patchApi(dynamic data, String url) async {
    dynamic responseJson;
    try {
      final response = await http
          .patch(Uri.parse(BASEURL + url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } on HttpException {
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> putApi(dynamic data, String url) async {
    dynamic responseJson;
    try {
      final response = await http
          .put(Uri.parse(BASEURL + url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } on HttpException {
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> patchApiWithHeaders(
      dynamic data, String url, Map<String, String>? headers) async {
    dynamic responseJson;
    try {
      final response = await http
          .patch(Uri.parse(BASEURL + url),
              headers: headers ?? {'Content-Type': 'application/json'},
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } on HttpException {
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  Future<dynamic> putApiWithHeaders(
      dynamic data, String url, Map<String, String>? headers) async {
    dynamic responseJson;
    try {
      final response = await http
          .put(Uri.parse(BASEURL + url),
              headers: headers ?? {'Content-Type': 'application/json'},
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException();
    } on TimeoutException {
      throw RequestTimeOutException();
    } on HttpException {
      throw FetchDataException('HTTP exception occurred');
    } on FormatException {
      throw FetchDataException('Invalid JSON format');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    final statusCode = response.statusCode;

    if (statusCode == 200 || statusCode == 201) {
      // If the response is successful, return the response body.
      return responseBody;
    } else if (statusCode == 400 || statusCode == 422) {
      throw InvalidUrlException(responseBody["message"] ?? "Invalid URL");
    } else if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(responseBody["message"] ?? "Unauthorized");
    } else if (statusCode == 409) {
      throw EmailAlreadyExistsException(
          responseBody["message"] ?? "Conflict occurred");
    } else if (statusCode == 500) {
      throw FetchDataException(
          responseBody["message"] ?? "Internal Server Error");
    } else {
      throw FetchDataException(
          'Unexpected error: ${response.statusCode}, ${responseBody["message"] ?? "Unknown error"}');
    }
  }
}
