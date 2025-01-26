import 'dart:convert';

import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/data/Network/network_api.dart';

class Paymentrepositry {
  final NetworkApiServices _apiServices = NetworkApiServices();
  final _tokenManager = SecureTokenManager();

  Future<void> balanceUpdate(
      String balanceId, bool paid, bool markAsPaid) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final Map<String, dynamic> data = {
        'balanceId': balanceId,
        'paid': paid,
        'markAsPaid': markAsPaid
      };
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      await _apiServices.postApiWithHeaders(data, '/update-balance', headers);
    } catch (e) {
      throw Exception('Update Balance Failed: $e');
    }
  }

  // Future<String> getBalanceId(String groupId, String expenseId) async {
  //   try {
  //     final accessToken = await _tokenManager.getAccessToken();
  //     final Map<String, dynamic> data = {
  //       'groupId': groupId,
  //       'expenseId': expenseId,
  //     };

  //     final Map<String, String> headers = {
  //       'authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     };
  //     print("yes");
  //     print(data.toString());

  //     final response =
  //         await _apiServices.postApiWithHeaders(data, '/getBalanceId', headers);

  //     // Debug: Print status code and response body
  //     print("Response Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //     print("yes");
  //     print(response.toString());
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print(data);
  //       print(data['data']);
  //       return data['data']; // Balance ID
  //     } else {
  //       throw Exception(jsonDecode(response.body)['message'] ??
  //           'Failed to fetch balance ID');
  //     }
  //   } catch (e) {
  //     throw Exception('Update Balance Failed: $e');
  //   }
  // }
  Future<String> getBalanceId(String groupId, String expenseId) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final Map<String, dynamic> data = {
        'groupId': groupId,
        'expenseId': expenseId,
      };

      final Map<String, String> headers = {
        'authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      try {
        final response = await _apiServices.postApiWithHeaders(
            data, '/getBalanceId', headers);

        // Check if the response is already a Map
        if (response is Map) {
          print("Response as Map: $response"); // If response is parsed
        } else {
          print("Raw Response: ${response.toString()}");
        }

        if (response['statusCode'] == 200) {
          final responseData = response;

          return responseData['data']; // Balance ID
        } else {
          throw Exception(response['message'] ?? 'Failed to fetch balance ID');
        }
      } catch (e) {
        print("Error in postApiWithHeaders: $e");
        rethrow; // Optional, propagate the exception
      }
    } catch (e) {
      print("General Exception: $e");
      throw Exception('Update Balance Failed: $e');
    }
  }
}
