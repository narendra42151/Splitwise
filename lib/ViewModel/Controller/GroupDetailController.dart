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
      final response = await _repository.fetchFromApi(
          groupId, page); // Replace with your API call logic
      if (response['success'] == true) {
        final data = response['data'];
        groupDetails.value = GroupModel.fromJson(data['group']);
        totalPages.value = data['totalPages'];
        if (page == 1) {
          expenses.assignAll(data['expenses']
              .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
              .toList());
        } else {
          expenses.addAll(data['expenses']
              .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
              .toList());
        }
      }
    } catch (e) {
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
