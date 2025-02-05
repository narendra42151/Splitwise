import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/Models/GetMessage.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Utils/Utils.dart';
import 'package:splitwise/View/Group/AmountScreen.dart';
import 'package:splitwise/View/Group/CardSplit.dart';
import 'package:splitwise/View/Group/PaymentDetailScreen.dart';
import 'package:splitwise/View/Group/SplitExpenseScreen.dart';
import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:splitwise/ViewModel/Controller/Undefined.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailsScreen({required this.groupId, super.key});

  @override
  State<StatefulWidget> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late IO.Socket socket;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  late String userId;

  @override
  void initState() {
    super.initState();
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

    connect(controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.mergedList.listen((list) {
        if (list.isNotEmpty) {
          _scrollToBottom();
        }
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void connect(Groupdetailcontroller controller) {
    userId = controller.authController.user.value!.userId ?? "";

    socket = IO.io("${SOCKETPROD}", <String, dynamic>{
      "transports": ['websocket'],
      "autoConnect": false,
    });

    socket.onConnectError((data) {
      log("${data}");
    });

    socket.onError((data) {
      log("${data}");
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('Id', {'userId': userId, 'groupId': widget.groupId});

      socket.on("messageEvent", (msg) {
        if (msg is Map<String, dynamic>) {
          controller.mergedList.add(
            UnifiedItem(
              createdAt: DateTime.now(), // Ensure 'createdAt' exists
              item: MessageGet(
                  messageId: "",
                  createdAt: DateTime.now().toString(),
                  groupId: msg['groupId'],
                  message: msg["message"],
                  createdBy: Members(
                      groupId: msg["createdBy"],
                      username: controller.groupDetails.value!
                          .getUserNameById(msg["createdBy"]))),
            ),
          );
          // Scroll to the bottom when a new message is added
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      });
    });
  }

  void sendMessage(
      {required List<String> revicerId,
      required Groupdetailcontroller controller}) {
    if (messageController.text.trim().isEmpty) return;

    socket.emit("messageEvent", {
      "userList": revicerId,
      "message": messageController.text.trim(),
      "createdBy": userId,
      "groupId": widget.groupId
    });

    messageController.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    messageController.dispose();
    messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Groupdetailcontroller>();
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.toNamed('/groupScreenList');
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
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
          const SizedBox(
            width: 10,
          ),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                controller.fetchGroupData(page: controller.currentPage.value);
                controller.fetchMessage(widget.groupId);
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildExpenseList(controller),
          ),
          if (controller.isMessageActive.value) _buildMessageInput(controller),
        ],
      ),
      floatingActionButton: Obx(() {
        return controller.isMessageActive.value
            ? const SizedBox.shrink()
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: FloatingActionButton(
                        heroTag: "message_button",
                        onPressed: () {
                          controller.isMessageActive.value = true;
                          FocusScope.of(context).requestFocus(messageFocusNode);
                        },
                        child: Icon(Icons.message),
                        backgroundColor: AppColors.lightPrimaryColor,
                      ),
                    ),
                    FloatingActionButton.extended(
                      heroTag: "split_button",
                      onPressed: () {
                        Get.to(
                            () => AmountInputScreen(groupId: widget.groupId));
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('Split Expense'),
                      backgroundColor: AppColors.lightPrimaryColor,
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildExpenseList(Groupdetailcontroller controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.mergedList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.mergedList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 64,
                color: AppColors.lightPrimaryColor, // Google Pay blue
              ),
              const SizedBox(height: 16),
              Text(
                'No expenses or messages yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
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
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: controller.mergedList.length,
            itemBuilder: (context, index) {
              final unifiedItem = controller.mergedList[index];
              if (unifiedItem.item is ExpenseModel) {
                final expense = unifiedItem.item as ExpenseModel;
                final isCurrentUserPaid =
                    expense.expenseDetails!.paidBy![0].groupId ==
                        controller.authController.user.value!.userId;
                return Align(
                  alignment: isCurrentUserPaid
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: _buildExpenseCard(expense, controller),
                );
              } else if (unifiedItem.item is MessageGet) {
                final message = unifiedItem.item as MessageGet;
                final isCurrentUserMessage = message.createdBy!.groupId ==
                    controller.authController.user.value!.userId;
                return Align(
                  alignment: isCurrentUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: _buildMessageBubble(message, isCurrentUserMessage),
                );
              } else {
                return const SizedBox.shrink(); // Handle unexpected types
              }
            },
          ),
          if (controller.isLoading.value && !controller.mergedList.isEmpty)
            const Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }

  Widget _buildExpenseCard(
      ExpenseModel expense, Groupdetailcontroller controller) {
    return SplitRequestCard(
      isRight: expense.expenseDetails!.paidBy![0].groupId ==
          controller.authController.user.value!.userId,
      onTap: () {
        Get.to(() => PaymentRequestScreen(
              expenseModel: expense,
            ));
      },
      groupId: widget.groupId,
      expenseModel: expense,
    );
  }

  Widget _buildMessageBubble(MessageGet message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.darkPrimaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message ?? '',
            style: TextStyle(
              fontSize: 16,
              color: isCurrentUser ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sent by: ${message.createdBy?.username ?? 'Unknown'}',
            style: TextStyle(
              fontSize: 12,
              color: isCurrentUser ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(Groupdetailcontroller controller) {
    return Obx(() {
      if (!controller.isMessageActive.value) {
        return const SizedBox.shrink(); // Hide the input field if not active
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                controller.isMessageActive.value = false;
              },
              icon: const Icon(
                Icons.arrow_left,
                color: Colors.blueGrey,
              ),
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                focusNode: messageFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value == "") {
                  } else {
                    controller.isSendShow.value = true;
                  }
                },
              ),
            ),
            if (controller.isSendShow.value)
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.darkPrimaryColor),
                onPressed: () {
                  List<String> memberIds = controller
                          .groupDetails.value?.members
                          ?.map((member) => member.groupId ?? "")
                          .where((id) => id.isNotEmpty)
                          .toList() ??
                      [];
                  print(memberIds);
                  sendMessage(revicerId: memberIds, controller: controller);
                },
              ),
          ],
        ),
      );
    });
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
      icon: const Icon(Icons.arrow_back),
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
                color: Colors.blue.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: AppColors.darkPrimaryColor,
                child: Icon(
                  Icons.receipt,
                  color: Colors.white,
                ),
              ),
              title: Text(
                expense.expenseDetails!.description ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Amount: ₹${expense.expenseDetails!.amount ?? 'N/A'}',
                style: const TextStyle(
                  color: AppColors.darkPrimaryColor,
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
