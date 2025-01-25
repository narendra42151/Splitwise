import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/View/Pay/PayService.dart';

class Payscreen extends StatefulWidget {
  final ExpenseModel expenseModel;
  Payscreen({required this.expenseModel, super.key});
  @override
  State<StatefulWidget> createState() {
    return _Payscreen();
  }
}

class _Payscreen extends State<Payscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
              child: IconButton(
                  onPressed: () {
                    Get.to(() => Screen());
                  },
                  icon: Icon(Icons.payment)))
        ],
      ),
    );
  }
}
