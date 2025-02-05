import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/Models/GetMessage.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Repositry/Group.repositry.dart';
import 'package:splitwise/Utils/CustomException.dart';
import 'package:splitwise/Utils/Errorhandler.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';
import 'package:splitwise/ViewModel/Controller/Undefined.dart';
import 'package:splitwise/data/AppException.dart';

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
  var error = ''.obs;
  var message = ''.obs;
  var messageList = <MessageGet>[].obs;
  var mergedList = <UnifiedItem>[].obs;
  var isSendShow = false.obs;
  var currentMessagePage = 1.obs;
  var totalMessagePages = 1.obs;
  var currentExpensePage = 1.obs;
  var totalExpensePages = 1.obs;

  var isMessageActive = false.obs;
  String groupId;
  final int limit;

  Groupdetailcontroller({required this.groupId, this.limit = 5});
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    mergedList.clear();
    fetchGroupData();
    fetchMessage(groupId);
    ever(groupDetails, (_) => initializeSplitSelection());
  }

  Future<void> loadOlderMessages() async {
    if (currentMessagePage.value < totalMessagePages.value) {
      currentMessagePage.value++;
      await fetchMessage(groupId, page: currentMessagePage.value);
    }
  }

  Future<void> loadOlderExpenses() async {
    if (currentExpensePage.value < totalExpensePages.value) {
      currentExpensePage.value++;
      await fetchGroupData(page: currentExpensePage.value);
    }
  }

  Future<void> fetchGroupData({int page = 1}) async {
    isLoading(true);
    try {
      // Fetch parsed response from the repository
      final response = await _repository.fetchFromApi(groupId, page);

      // Validate response structure
      if (!response.containsKey('data')) {
        throw Exception('Invalid response format: Missing "data" key');
      }

      if (response['success'] == true) {
        final data = response['data'];

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
        mergeAndSortItems();
      } else {
        throw Exception(response['message'] ?? 'Unknown error occurred');
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

  Future<void> fetchMessage(String groupId, {int page = 1}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final fullResponse = await _repository.getMessage(groupId, page);

      // Validate response structure
      if (fullResponse['data'] == null ||
          fullResponse['data']['docs'] == null) {
        throw AppException('Invalid response format', 'Please try again later');
      }

      List<dynamic> messages = fullResponse['data']['docs'];

      final totalPagesFromApi = fullResponse['data']['totalPages'] ?? 1;

      // Update pagination state
      totalMessagePages.value = totalPagesFromApi;
      currentMessagePage.value = page;

      // Handle message list update
      if (page == 1) {
        messageList.value =
            messages.map((msg) => MessageGet.fromJson(msg)).toList();
      } else {
        messageList
            .addAll(messages.map((msg) => MessageGet.fromJson(msg)).toList());
      }

      mergeAndSortItems();
    } catch (e) {
      error.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to fetch messages',
        backgroundColor: const Color.fromARGB(255, 106, 106, 108),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExpense(
      {required String groupId,
      required String description,
      required double amount,
      required String paidBy,
      required List<String> splitAmong,
      required String splitType,
      required Map<String, double> manualSplit,
      required BuildContext context}) async {
    try {
      isLoading(true);
      // print(splitAmong.toString());
      await _repository.createExpense(
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitAmong: splitAmong,
        splitType: splitType,
        manualSplit: manualSplit,
      );

      Get.snackbar("Success", "Expense created successfully!",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      error.value = e.toString();

      if (e is AppException) {
        ErrorHandler.handleError(e, context);
      } else if (e is Exception) {
        ErrorHandler.handleError(CustomException(error.value), context);
      } else {
        ErrorHandler.handleError(e, context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void mergeAndSortItems() {
    final List<UnifiedItem> unifiedItems = [];

    // Add expenses to the unified list
    for (var expense in expenses) {
      if (expense.expenseDetails?.createdAt != null) {
        unifiedItems.add(
          UnifiedItem(
            createdAt: DateTime.parse(expense.expenseDetails!.createdAt!),
            item: expense,
          ),
        );
      }
    }

    // Add messages to the unified list
    for (var message in messageList) {
      if (message.createdAt != null) {
        unifiedItems.add(
          UnifiedItem(
            createdAt: DateTime.parse(message.createdAt!),
            item: message,
          ),
        );
      }
    }

    // Sort the unified list by createdAt in ascending order (newest at the bottom)
    unifiedItems
        .sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Oldest first

    // Update the mergedList observable
    mergedList.assignAll(unifiedItems);
  }
}
