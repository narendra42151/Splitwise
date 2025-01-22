import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  @override
  Widget build(BuildContext context) {
    final Groupdetailcontroller controller = Get.put(
      Groupdetailcontroller(groupId: widget.groupId),
    );
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
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.expenses.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.expenses.length) {
              // Pagination
              return controller.currentPage.value < controller.totalPages.value
                  ? ElevatedButton(
                      onPressed: () {
                        controller.currentPage.value++;
                        controller.fetchGroupData(
                            page: controller.currentPage.value);
                      },
                      child: Text('Load More'),
                    )
                  : SizedBox.shrink();
            }

            final expense = controller.expenses[index];
            return ListTile(
              title: Text(expense.expenseDetails!.description ?? ""),
              subtitle: Text('Amount: ${expense.expenseDetails!.amount ?? ''}'),
            );
          },
        );
      }),
    );
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
            subtitle: Text('Amount: ${expense.expenseDetails!.amount ?? ''}'),
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
