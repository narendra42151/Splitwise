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
  final selectedMembers = <bool>[].obs;
  final splitAmounts = <double>[].obs;

  final String groupId;
  final int limit;

  Groupdetailcontroller({required this.groupId, this.limit = 5});

  @override
  void onInit() {
    super.onInit();
    fetchGroupData();
    ever(groupDetails, (_) => initializeSplitSelection());
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

  void initializeSplitSelection() {
    final membersCount = groupDetails.value?.members?.length ?? 0;

    // Initialize all members as selected
    selectedMembers.assignAll(List.generate(membersCount, (index) => true));

    // Initialize split amounts with equal distribution
    splitAmounts.assignAll(List.generate(membersCount, (index) => 0.0));
  }

  void toggleMemberSelection(int index) {
    if (index < selectedMembers.length) {
      selectedMembers[index] = !selectedMembers[index];
    }
  }

  void calculateSplitAmount(String totalAmountStr) {
    final totalAmount = double.tryParse(totalAmountStr) ?? 0.0;

    // Calculate the number of selected members
    final selectedCount =
        selectedMembers.where((isSelected) => isSelected).length;

    // If no members are selected, reset split amounts
    if (selectedCount == 0) {
      splitAmounts
          .assignAll(List.generate(selectedMembers.length, (index) => 0.0));
      return;
    }

    // Calculate split amount
    final splitAmount = totalAmount / selectedCount;

    // Update split amounts based on selection
    splitAmounts.assignAll(List.generate(selectedMembers.length, (index) {
      return selectedMembers[index] ? splitAmount : 0.0;
    }));
  }

  List<String> getSelectedMembersUserIds() {
    final members = groupDetails.value?.members ?? [];
    final userIds = <String>[];

    for (int i = 0; i < members.length; i++) {
      if (selectedMembers[i]) {
        userIds.add(members[i].groupId ?? ""); // Add user ID to the list
      }
    }

    return userIds;
  }

  Future<void> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required String splitType,
    required Map<String, double> manualSplit,
  }) async {
    try {
      isLoading(true);
      // print(splitAmong.toString());
      final response = await _repository.createExpense(
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitAmong: splitAmong,
        splitType: splitType,
        manualSplit: manualSplit,
      );

      if (response != null) {
        Get.snackbar("Success", "Expense created successfully!",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create expense: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }
}
