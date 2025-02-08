import 'package:splitwise/Models/UserModel.dart';
import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/data/AppException.dart';
import 'package:splitwise/data/Network/network_api.dart';

class AuthRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();
  final _tokenManager = SecureTokenManager();

  Future<UserModel> registerUser(String username, String profilePicture,
      String phoneNumber, String password, String upiId) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'profilePicture': profilePicture,
        'phoneNumber': phoneNumber,
        'password': password,
        'upiId': upiId
      };

      final response = await _apiServices.postApi(
        data,
        '/register',
      );
      print(response.toString());

      return UserModel.fromJson(response['data']);
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Registration failed: $e');
      }
    }
  }

  Future<Map<String, dynamic>> loginUser(
      String phoneNumber, String password) async {
    try {
      final Map<String, dynamic> data = {
        'phoneNumber': phoneNumber,
        'password': password
      };

      // Make API call
      final response = await _apiServices.postApi(data, '/login');

      if (response == null) {
        throw Exception('Response is null');
      }

      // Directly use the response as it's already a Map
      final Map<String, dynamic>? jsonResponse =
          response as Map<String, dynamic>?;

      if (jsonResponse == null || !jsonResponse.containsKey('data')) {
        throw Exception('Invalid response format');
      }

      final user = jsonResponse['data']['user'];
      if (user == null) {
        throw Exception('User data is null');
      }
      final accessToken = jsonResponse['data']['accessToken'];
      final refreshToken = jsonResponse['data']['refreshToken'];

      // Securely store tokens

      await _tokenManager.saveTokens(accessToken, refreshToken);
      return {
        'user': UserModel.fromJson(user),
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      await _apiServices.postApi('/logout', "");
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<UserModel> updateUserDetails(
      String username, String profilePicture) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'profilePicture': profilePicture
      };

      final response = await _apiServices.putApi(data, '/user/update');
      return UserModel.fromJson(response['user']);
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Update failed: $e');
      }
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final Map<String, dynamic> data = {
        'oldPassword': oldPassword,
        'newPassword': newPassword
      };
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      await _apiServices.postApiWithHeaders(data, '/change-password', headers);
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Password change failed: $e'); // Wrap others
      }
    }
  }

  Future<UserModel> getUserDetails() async {
    try {
      final accessToken = await _tokenManager.getAccessToken();

      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.getApiWithHeaders('/get-user', headers);

      final Map<String, dynamic>? jsonResponse =
          response as Map<String, dynamic>?;

      if (jsonResponse == null || !jsonResponse.containsKey('data')) {
        throw Exception('Invalid response format');
      }

      final user = jsonResponse['data'];
      if (user == null) {
        throw Exception('User data is null');
      }

      return UserModel.fromJson(user);
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to fetch user details: $e');
      }
    }
  }

  Future<dynamic> userRefreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();

      final Map<String, String> headers = {
        'refresh_token': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      };

      final response =
          await _apiServices.getApiWithHeaders('/refresh-token', headers);
      print(response.toString());

      final Map<String, dynamic>? jsonResponse =
          response as Map<String, dynamic>?;

      if (jsonResponse == null || !jsonResponse.containsKey('data')) {
        throw Exception('Invalid response format');
      }

      final tokens = jsonResponse['data'];
      print(tokens);
      if (tokens == null) {
        throw Exception('No Refresh Token');
      }

      if (jsonResponse["message"] == "Token refreshed successfully") {
        return tokens;
      }

      throw Exception("Some Error Occurred");
    } catch (e) {
      if (e is AppException) {
        throw e; // Re-throw AppException
      } else {
        throw Exception('Failed to Referesh Token: $e');
      }
    }
  }
}
