import 'package:splitwise/Models/UserModel.dart';
import 'package:splitwise/data/Network/network_api.dart';

class AuthRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<UserModel> registerUser(String username, String profilePicture,
      String phoneNumber, String password) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'profilePicture': profilePicture,
        'phoneNumber': phoneNumber,
        'password': password
      };

      final response = await _apiServices.postApi(
        data,
        '/register',
      );
      return UserModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(
      String phoneNumber, String password) async {
    try {
      final Map<String, dynamic> data = {
        'phoneNumber': phoneNumber,
        'password': password
      };

      final response = await _apiServices.postApi(data, '/login');
      return {
        'user': UserModel.fromJson(response['user']),
        'accessToken': response['accessToken'],
        'refreshToken': response['refreshToken']
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
      throw Exception('Update failed: $e');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final Map<String, dynamic> data = {
        'oldPassword': oldPassword,
        'newPassword': newPassword
      };

      await _apiServices.putApi(data, '/user/update');
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }
}
