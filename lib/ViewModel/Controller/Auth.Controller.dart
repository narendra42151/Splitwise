import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/ServerDownScreen.dart';
import 'package:splitwise/Models/UserModel.dart';
import 'package:splitwise/Repositry/Auth.repositry.dart';
import 'package:splitwise/Utils/CustomException.dart';
import 'package:splitwise/Utils/Errorhandler.dart';
import 'package:splitwise/Utils/SnackBar.dart';
import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/data/AppException.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final _tokenManager = SecureTokenManager();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isPasswordVisible = false.obs;

  Future<void> register(
      String username,
      String profilePicture,
      String phoneNumber,
      String password,
      String upiId,
      BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final newUser = await _repository.registerUser(
          username, profilePicture, phoneNumber, password, upiId);

      user.value = newUser;

      Get.toNamed('/login');
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(
      String phoneNumber, String password, BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.loginUser(phoneNumber, password);

      user.value = response['user'];
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
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

  Future<void> updateUserDetails(
      String username, String profilePicture, BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedUser =
          await _repository.updateUserDetails(username, profilePicture);
      user.value = updatedUser;

      showCustomSnackBar(context, "Profile updated successfully");
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(
      {required String oldPassword,
      required String newPassword,
      required BuildContext context}) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.changePassword(oldPassword, newPassword);

      showCustomSnackBar(context, "Password changed successfully");
      Get.toNamed("/home");
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      }
      // Then check for general Exception
      else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Future<dynamic> getUserDetails(BuildContext context) async {
  //   try {
  //     isLoading.value = true;
  //     error.value = '';

  //     final userDetails = await _repository.getUserDetails();

  //     user.value = userDetails;

  //     if (user.value == null) {
  //       Get.toNamed("/login");
  //     } else {
  //       Get.offAllNamed('/home');
  //     }

  //     return user.value;
  //   } catch (e) {
  //     error.value = e.toString();

  //     if (e is AppException) {
  //       print("App Exception: ${e.getType()}");
  //       print(e.getType().toString());
  //       e.getType().toString() == "UnauthorizedException"
  //           ? Get.toNamed("/login")
  //           : Get.to(() => ServerDownScreen(
  //               isLogin: e.getType().toString() == "UnauthorizedException"
  //                   ? false
  //                   : true,
  //               server: true));
  //     } else if (e is Exception) {
  //       ErrorHandler.handleError(CustomException(error.value), context);
  //     } else {
  //       ErrorHandler.handleError(e, context);
  //     }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<dynamic> refreshToken(BuildContext context) async {
  //   try {
  //     isLoading.value = true;
  //     error.value = '';

  //     final userDetails = await _repository.userRefreshToken();

  //     print(userDetails);

  //     return user.value;
  //   } catch (e) {
  //     error.value = e.toString();

  //     if (e is AppException) {
  //       ErrorHandler.handleError(e, context);
  //     }
  //     // Then check for general Exception
  //     else if (e is Exception) {
  //       ErrorHandler.handleError(CustomException(error.value), context);
  //     } else {
  //       ErrorHandler.handleError(e, context);
  //     }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<dynamic> getUserDetails(BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userDetails = await _repository.getUserDetails();

      user.value = userDetails;

      if (user.value == null) {
        Get.toNamed("/login");
      } else {
        Get.offAllNamed('/home');
      }

      return user.value;
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        print("App Exception: ${e.getType()}");
        print(e.getType().toString());
        if (e.getType().toString() == "UnauthorizedException") {
          // Call refreshToken when unauthorized
          print("1 go for rft");
          bool refreshSuccess = await refreshToken(context);
          if (refreshSuccess) {
            // If refreshToken is successful, call getUserDetails again
            print("2 ");
            return await getUserDetails(context);
          } else {
            // If refreshToken fails, navigate to login screen
            Get.toNamed("/login");
          }
        } else {
          Get.to(() => ServerDownScreen(
              isLogin: e.getType().toString() == "UnauthorizedException"
                  ? false
                  : true,
              server: true));
        }
      } else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> refreshToken(BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final tokens = await _repository.userRefreshToken();
      await _tokenManager.saveTokens(
          tokens["accessToken"], tokens["refreshTokens"]);

      // Assuming userDetails contains the new token and user is now authorized
      // You might want to update the user value or token here

      return true; // Return true if refresh is successful
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      }
      // Then check for general Exception
      else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }

      return false; // Return false if refresh fails
    } finally {
      isLoading.value = false;
    }
  }
}
