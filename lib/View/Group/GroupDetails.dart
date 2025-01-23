import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/View/Group/AmountScreen.dart';
import 'package:splitwise/View/Group/CardSplit.dart';
import 'package:splitwise/View/Group/PaymentDetailScreen.dart';

import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  GroupDetailsScreen({required this.groupId, super.key});

  @override
  State<StatefulWidget> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Remove existing controller if it exists
    if (Get.isRegistered<Groupdetailcontroller>()) {
      Get.delete<Groupdetailcontroller>();
    }

    final controller = Get.put(Groupdetailcontroller(groupId: widget.groupId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          controller.currentPage.value < controller.totalPages.value) {
        controller.currentPage.value++;
        controller.fetchGroupData(page: controller.currentPage.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Groupdetailcontroller>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.toNamed('/groupScreenList');
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          'Group Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ExpenseSearchDelegate(controller),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement split expense logic
          Get.to(() => AmountInputScreen());
        },
        icon: Icon(Icons.group_add),
        label: Text('Split Expense'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.expenses.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No expenses yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 80),
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                return SplitRequestCard(
                  onTap: () {
                    Get.to(() => PaymentRequestScreen(
                          expenseModel: expense,
                        ));
                  },
                  expenseModel: expense,
                );
              },
            ),
            if (controller.isLoading.value && !controller.expenses.isEmpty)
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ExpenseSearchDelegate extends SearchDelegate {
  final Groupdetailcontroller controller;
  ExpenseSearchDelegate(this.controller);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          controller.searchExpenses('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.searchExpenses(query);
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  Widget buildSearchResults(BuildContext context) {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final expense = controller.searchResults[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.receipt,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              title: Text(
                expense.expenseDetails!.description ?? "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Amount: ${expense.expenseDetails!.amount ?? 'N/A'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
