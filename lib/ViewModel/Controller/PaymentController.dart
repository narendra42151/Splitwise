import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Repositry/PaymentRepositry.dart';
import 'package:splitwise/Utils/CustomException.dart';
import 'package:splitwise/Utils/Errorhandler.dart';
import 'package:splitwise/Utils/SnackBar.dart';
import 'package:splitwise/data/AppException.dart';

class Paymentcontroller extends GetxController {
  final Paymentrepositry _repository = Paymentrepositry();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString balanceId = "".obs;

  Future<dynamic> fetchBalanceId(
      String groupId, String expenseId, BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      final id = await _repository.getBalanceId(groupId, expenseId);

      balanceId.value = id;
      if (id == "") {
        return false;
      }
      return true;
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

  Future<void> updateBalance(
      bool paid, bool markAsPaid, BuildContext context) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.balanceUpdate(balanceId.value, paid, markAsPaid);

      // Show success message

      showCustomSnackBar(context, "Balance updated successfully");
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
}
