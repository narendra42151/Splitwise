import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/Utils/SnackBar.dart';

class PaymentRequestScreen extends StatelessWidget {
  final ExpenseModel expenseModel;
  final ThemeController themeController = Get.find();

  PaymentRequestScreen({super.key, required this.expenseModel});

  @override
  Widget build(BuildContext context) {
    final creator = expenseModel.expenseDetails?.paidBy?.first;
    final splitAmong = expenseModel.expenseDetails?.splitAmong ?? [];
    final totalAmount = expenseModel.expenseDetails?.amount ?? 0.0;

    // Calculate split amount considering potential division by zero
    final splitAmount = totalAmount / (splitAmong.length);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Payment Request',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Colors.blueGrey.shade900,
                    Colors.black,
                  ]
                : [
                    Colors.blue.shade100,
                    Colors.white,
                  ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section (unchanged)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Hero(
                    tag: 'profile_${creator?.username}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: const AssetImage('assets/me.png'),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${creator?.username ?? "Unknown"} requested',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'You paid',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                thickness: 0.5),
            // List Section (modified)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                '${splitAmong.length + 1} of ${splitAmong.length + 1} to pay',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: splitAmong.length,
                itemBuilder: (context, index) {
                  final participant = splitAmong[index];

                  // Check if participant is in paidBy list
                  final isPaid = expenseModel.expenseDetails?.paidBy?.any(
                        (paidMember) =>
                            paidMember.groupId == participant.groupId,
                      ) ??
                      false;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        participant.username?.substring(0, 1) ?? '?',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      participant.username ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${splitAmount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (isPaid)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                thickness: 0.5),
            // Total Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle payment confirmation

          showCustomSnackBar(context, 'Payment request confirmed');
        },
        label: const Text('Confirm Payment'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
