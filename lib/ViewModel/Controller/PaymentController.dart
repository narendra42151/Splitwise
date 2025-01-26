import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Repositry/PaymentRepositry.dart';

class Paymentcontroller extends GetxController {
  final Paymentrepositry _repository = Paymentrepositry();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString balanceId = "".obs;

  Future<bool> fetchBalanceId(String groupId, String expenseId) async {
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
      return false;
    } finally {
      isLoading.value = false;
      return false;
    }
  }

  Future<void> updateBalance(bool paid, bool markAsPaid) async {
    try {
      isLoading.value = true;
      error.value = '';
      print("Balance ID");
      print(balanceId.value);

      await _repository.balanceUpdate(balanceId.value, paid, markAsPaid);

      // Show success message
      Get.snackbar(
        "Success",
        "Balance updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      print(error.value);

      // Show error message
      Get.snackbar(
        "Error",
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
