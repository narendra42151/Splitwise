import 'dart:convert';

import 'package:get/get.dart';

import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Repositry/Group.repositry.dart';

class Groupdetailcontroller extends GetxController {
  final GroupRepository _repository = GroupRepository();
  var isLoading = true.obs;
  var groupDetails = Rxn<GroupModel>();
  var expenses = <ExpenseModel>[].obs;
  var searchResults = <ExpenseModel>[].obs;
  var totalPages = 1.obs;
  var currentPage = 1.obs;
  var query = "".obs;

  final String groupId;
  final int limit;

  Groupdetailcontroller({required this.groupId, this.limit = 5});

  @override
  void onInit() {
    super.onInit();
    fetchGroupData();
  }

  Future<void> fetchGroupData({int page = 1}) async {
    isLoading(true);
    try {
      // Fetch parsed response from the repository
      final response = await _repository.fetchFromApi(groupId, page);

      print("From Controller");
      print(response.toString());

      // Validate response structure
      if (!response.containsKey('data')) {
        throw Exception('Invalid response format: Missing "data" key');
      }

      if (response['success'] == true) {
        final data = response['data'];
        print(data['group']);

        // Update group details

        groupDetails.value = GroupModel.fromJson(data['group']);

        // Update pagination details
        totalPages.value = data['totalPages'];

        // Handle expenses based on pagination
        if (page == 1) {
          expenses.assignAll(data['expenses']
              .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
              .toList());
        } else {
          expenses.addAll(data['expenses']
              .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
              .toList());
        }
      } else {
        throw Exception(response['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void searchExpenses(String query) {
    this.query.value = query;
    if (query.isEmpty) {
      searchResults.assignAll(expenses);
    } else {
      searchResults.assignAll(
        expenses
            .where((expense) => expense.expenseDetails!.description!
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}
