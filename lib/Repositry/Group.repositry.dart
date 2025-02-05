import 'dart:convert';

import 'package:get/get.dart';
import 'package:splitwise/Models/CustomContact.dart';
import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/data/AppException.dart';

import 'package:splitwise/data/Network/network_api.dart';

class GroupRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();
  final _tokenManager = SecureTokenManager();

  // Create a group
  Future<dynamic> createGroup(
      String name, RxList<CustomContact> members, String ownerId) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final List<String> userIds = members
          .map((contact) =>
              contact.userId ?? '') // Use empty string if userId is null
          .where((id) => id.isNotEmpty) // Remove empty strings if any
          .toList();
      if (ownerId.isNotEmpty) {
        userIds.add(ownerId);
      }

      final Map<String, dynamic> data = {
        'name': name,
        'members': userIds, // List of userIds as strings
      };

      final Map<String, String> headers = {
        'authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.postApiWithHeaders(data, '/create-group', headers);

      return response['data'];
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to create group: $e');
      }
    }
  }

  // Get group details
  Future<dynamic> getGroupDetails(String groupId) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.getApiWithHeaders('/get-group/$groupId', headers);
      return response['data'];
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to fetch group details: $e');
      }
    }
  }

  // Update group details
  Future<dynamic> updateGroupDetails(
      String groupId, String name, RxList<CustomContact> members) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final List<String> userIds = members
          .map((contact) =>
              contact.userId ?? '') // Use empty string if userId is null
          .where((id) => id.isNotEmpty) // Remove empty strings if any
          .toList();

      final Map<String, dynamic> data = {
        'name': name,
        'members': userIds, // List of userIds as strings
      };

      final Map<String, String> headers = {
        'authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await _apiServices.postApiWithHeaders(
          data, '/update-group/${groupId}', headers);

      return response['data'];
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to update group details: $e');
      }
    }
  }

  Future<Map<String, dynamic>> checkContactInDatabase(
      String phoneNumber) async {
    try {
      final Map<String, dynamic> data = {'phoneNumber': phoneNumber};

      // API call to check the contact
      final response = await _apiServices.postApi(data, '/check-phoneNumber');

      if (response == null || !response.containsKey('data')) {
        throw Exception('Invalid response from server');
      }

      return response['data'];
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to check contact in database: $e');
      }
    }
  }

  Future<List<dynamic>> getUserGroups() async {
    try {
      final accessToken = await _tokenManager.getAccessToken();

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.getApiWithHeaders('/get-group-userId', headers);

      return response['data'];
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to fetch user groups: $e');
      }
    }
  }

  Future<dynamic> fetchFromApi(String groupId, int page) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();

      final Map<String, String> headers = {
        // 'Authorization': 'Bearer $accessToken',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Make the API call
      final response = await _apiServices.getApiWithHeaders(
          '/get-group/${groupId}?limit=5&page=${page}', headers);

      // Parse the response body if it's a string
      if (response is String) {
        return jsonDecode(response) as Map<String, dynamic>;
      }

      // If already a Map, return it
      if (response is Map<String, dynamic>) {
        return response;
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to fetch user groups: $e');
      }
    }
  }

  Future<dynamic> getMessage(String groupId, int page) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();

      final Map<String, String> headers = {
        'authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Fetch the response
      final response = await _apiServices.getApiWithHeaders(
        '/get-message/$groupId?page=$page&limit=15',
        headers,
      );

      // Check if the response is null or empty
      if (response == null || response.isEmpty) {
        throw Exception('Empty response from server');
      }

      // No need to decode the response if it's already a Map
      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected a Map');
      }

      // Validate the response structure
      if (!response.containsKey('data')) {
        throw Exception('Invalid response format: Missing "data" field');
      }

      return response;
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to fetch messages: $e');
      }
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required String splitType,
    required Map<String, double> manualSplit,
  }) async {
    try {
      // Get the access token
      final accessToken = await _tokenManager.getAccessToken();

      // Define headers
      final Map<String, String> headers = {
        'authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "groupId": groupId,
        "description": description,
        "amount": amount,
        "paidBy": [paidBy], // Single user ID in a list
        "splitAmong": splitAmong,
        "splitType": splitType,
        // "manualSplit": manualSplit.isEmpty ? {} : manualSplit,
      };

      // Make the API call
      final response = await _apiServices.postApiWithHeaders(
        requestBody,
        '/create-expence', // Ensure the endpoint spelling is correct
        headers,
      );

      // Parse response
      if (response is String) {
        return jsonDecode(response) as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Unexpected response format: $response');
      }
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to create expense: $e');
      }
    }
  }
}
