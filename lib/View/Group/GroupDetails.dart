import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  GroupDetailsScreen({required this.groupId, super.key});

  @override
  State<StatefulWidget> createState() {
    return _GroupDetailsScreenState();
  }
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch initial group data
    final Groupdetailcontroller controller = Get.put(
      Groupdetailcontroller(groupId: widget.groupId),
    );

    // Add listener to detect when scrolling reaches near the bottom
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
    final Groupdetailcontroller controller = Get.find<Groupdetailcontroller>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ExpenseSearchDelegate(controller),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.expenses.isEmpty) {
          // Show a loading indicator initially
          return Center(child: CircularProgressIndicator());
        }

        if (controller.expenses.isEmpty) {
          // Show a placeholder message when no expenses are available
          return Center(
            child: Text(
              'No expenses found for this group.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController, // Attach the ScrollController
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                return ListTile(
                  title: Text(expense.expenseDetails!.description ?? ""),
                  subtitle: Text(
                      'Amount: ${expense.expenseDetails!.amount ?? 'N/A'}'),
                );
              },
            ),
            if (controller.isLoading.value && !controller.expenses.isEmpty)
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(), // Loading indicator
                ),
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
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.searchExpenses(query);
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return Center(child: Text('No results found'));
      }
      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final expense = controller.searchResults[index];
          return ListTile(
            title: Text(expense.expenseDetails!.description ?? ""),
            subtitle:
                Text('Amount: ${expense.expenseDetails!.amount ?? 'N/A'}'),
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
