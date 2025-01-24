import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'SplitExpenseScreen.dart';

class AmountInputScreen extends StatelessWidget {
  final String groupId;
  AmountInputScreen({super.key, required this.groupId});
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Expense Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Enter Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  final description = descriptionController.text;

                  if (amount <= 0 || description.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Please enter a valid amount and description.",
                    );
                    return;
                  }

                  // Navigate to the second screen with entered data
                  Get.to(() => SplitExpenseScreen(
                        gpId: groupId,
                        amount: amount,
                        description: description,
                      ));
                },
                child: Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
