import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/data/Network/network_api.dart';

class GroupRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();
  final _tokenManager = SecureTokenManager();

  // Create a group
  Future<dynamic> createGroup(String name, List<String> members) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final Map<String, dynamic> data = {
        'name': name,
        'members': members,
      };

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.postApiWithHeaders(data, '/groups', headers);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to create group: $e');
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
          await _apiServices.getApiWithHeaders('/groups/$groupId', headers);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to fetch group details: $e');
    }
  }

  // Update group details
  Future<dynamic> updateGroupDetails(
      String groupId, String name, List<String> members) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final Map<String, dynamic> data = {
        'name': name,
        'members': members,
      };

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await _apiServices.putApiWithHeaders(
          data, '/groups/$groupId', headers);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to update group details: $e');
    }
  }

  Future<bool> checkContactInDatabase(String phoneNumber) async {
    try {
      final Map<String, dynamic> data = {'phoneNumber': phoneNumber};

      // API call to check the contact
      final response = await _apiServices.postApi(data, '/check-phoneNumber');

      if (response == null || !response.containsKey('data')) {
        throw Exception('Invalid response from server');
      }

      final exists = response['data']['exists'];
      if (exists == null || exists is! bool) {
        throw Exception('Response does not contain a valid "exists" field');
      }

      return exists;
    } catch (e) {
      throw Exception('Failed to check contact in database: $e');
    }
  }
}
