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
      print("hello Id");

      final id = await _repository.getBalanceId(groupId, expenseId);
      print(id.toLowerCase().toString());
      balanceId.value = id;
      if (id == "" || id == null) {
        return false;
      }
      return true;
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        print("App Exception: ${e.getType()}");
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        print("Generic Exception");
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        print("Non-Exception error: $e");
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
      print("Balance ID");
      print(balanceId.value);

      await _repository.balanceUpdate(balanceId.value, paid, markAsPaid);

      // Show success message

      showCustomSnackBar(context, "Balance updated successfully");
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        print("App Exception: ${e.getType()}");
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        print("Generic Exception");
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        print("Non-Exception error: $e");
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
