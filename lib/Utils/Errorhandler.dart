import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Utils/CustomException.dart';
import 'package:splitwise/Utils/SnackBar.dart';
import 'package:splitwise/data/AppException.dart';

class ErrorHandler {
  static void handleError(dynamic error, BuildContext context) {
    if (error is SocketException) {
      Get.offAllNamed('/internet-exception');
    } else if (error is TimeoutException) {
      Get.off('/server-exception');
    } else if (error is UnauthorizedException) {
      Get.offAllNamed('/login');
    } else if (error is CustomException) {
      showCustomSnackBar(context, error.message);
    } else if (error is InternetException) {
      Get.offAllNamed('/internet-exception');
    } else if (error is FetchDataException) {
      showCustomSnackBar(context, error.toString());
    } else if (error is RequestTimeOutException) {
      Get.offAllNamed('/server-exception');
    } else if (error is ServerException) {
      Get.offAllNamed('/server-exception');
    } else if (error is InvalidUrlException) {
      showCustomSnackBar(context, "Some Url Exception is Their");
    } else {
      Get.offAllNamed('/login');
    }
  }
}
