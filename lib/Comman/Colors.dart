import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

// Color Schemes
class AppColors {
  // Light Theme Colors
  static const lightPrimaryColor = Color(0xFF6200EE);
  static const lightSecondaryColor = Color(0xFF03DAC6);
  static const lightBackgroundColor = Color(0xFFF5F5F5);
  static const lightErrorColor = Color(0xFFB00020);
  static const lightTextColor = Color(0xFF333333);

  // Dark Theme Colors
  static const darkPrimaryColor = Color(0xFFBB86FC);
  static const darkSecondaryColor = Color(0xFF03DAC6);
  static const darkBackgroundColor = Color(0xFF121212);
  static const darkErrorColor = Color(0xFFCF6679);
  static const darkTextColor = Color(0xFFFFFFFF);
}
