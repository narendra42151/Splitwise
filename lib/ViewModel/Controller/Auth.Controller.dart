import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/UserModel.dart';
import 'package:splitwise/Repositry/Auth.repositry.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isPasswordVisible = false.obs;

  Future<void> register(String username, String profilePicture,
      String phoneNumber, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final newUser = await _repository.registerUser(
          username, profilePicture, phoneNumber, password);
      user.value = newUser;
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String phoneNumber, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.loginUser(phoneNumber, password);
      user.value = response['user'];
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.logoutUser();
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserDetails(String username, String profilePicture) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedUser =
          await _repository.updateUserDetails(username, profilePicture);
      user.value = updatedUser;
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update profile',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.changePassword(oldPassword, newPassword);
      Get.back();
      Get.snackbar('Success', 'Password changed successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to change password',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}