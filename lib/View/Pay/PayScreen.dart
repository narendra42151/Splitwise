import 'package:flutter/material.dart';
import 'package:splitwise/Models/ExpenseModel.dart';

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
            child:
                Text("${widget.expenseModel.expenseDetails!.paidBy![0].upiId}"),
          )
        ],
      ),
    );
  }
}
