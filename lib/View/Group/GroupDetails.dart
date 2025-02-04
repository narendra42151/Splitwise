import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/ExpenseModel.dart';
import 'package:splitwise/Models/GetMessage.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Utils/Utils.dart';
import 'package:splitwise/View/Group/AmountScreen.dart';
import 'package:splitwise/View/Group/CardSplit.dart';
import 'package:splitwise/View/Group/PaymentDetailScreen.dart';
import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:splitwise/ViewModel/Controller/Undefined.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  GroupDetailsScreen({required this.groupId, super.key});

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
    print("User ID: $userId");

    socket = IO.io("${SOCKETPROD}", <String, dynamic>{
      "transports": ['websocket'],
      "autoConnect": false,
    });

    socket.onConnectError((data) {
      print("Socket Connection Error: $data");
    });

    socket.onError((data) {
      print("Socket General Error: $data");
    });

    socket.connect();

    socket.onConnect((_) {
      print("Socket Connected!");
      socket.emit('Id', {'userId': userId, 'groupId': widget.groupId});

      socket.on("messageEvent", (msg) {
        print("Received message from server: $msg");
        if (msg is Map<String, dynamic>) {
          controller.mergedList.add(
            UnifiedItem(
              createdAt: DateTime.now(), // Ensure 'createdAt' exists
              item: MessageGet(
                  messageId: "",
                  createdAt: DateTime.now().toString(),
                  groupId: msg['groupId'],
                  message: msg["message"],
                  createdBy: Members(groupId: msg["createdBy"])),
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
          print("Added to List");
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
          SizedBox(
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
      floatingActionButton: controller.isMessageActive.value
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => AmountInputScreen(
                      groupId: widget.groupId,
                    ));
              },
              icon: Icon(Icons.group_add),
              label: Text('Split Expense'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
      body: Column(
        children: [
          Expanded(
            child: _buildExpenseList(controller),
          ),
          if (controller.isMessageActive.value) _buildMessageInput(controller),
        ],
      ),
      bottomNavigationBar: controller.isMessageActive.value
          ? null
          : BottomAppBar(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    controller.isMessageActive.value = true;
                    FocusScope.of(context).requestFocus(messageFocusNode);
                  },
                ),
              ],
            )),
    );
  }

  Widget _buildExpenseList(Groupdetailcontroller controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.mergedList.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.mergedList.isEmpty) {
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
                'No expenses or messages yet',
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
            itemCount: controller.mergedList.length,
            itemBuilder: (context, index) {
              final unifiedItem = controller.mergedList[index];
              if (unifiedItem.item is ExpenseModel) {
                final expense = unifiedItem.item as ExpenseModel;
                return SplitRequestCard(
                  onTap: () {
                    Get.to(() => PaymentRequestScreen(
                          expenseModel: expense,
                        ));
                  },
                  groupId: widget.groupId,
                  expenseModel: expense,
                );
              } else if (unifiedItem.item is MessageGet) {
                final message = unifiedItem.item as MessageGet;
                return _buildMessageItem(message);
              } else {
                return SizedBox.shrink(); // Handle unexpected types
              }
            },
          ),
          if (controller.isLoading.value && !controller.mergedList.isEmpty)
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }

  Widget _buildMessageItem(MessageGet message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Sent by: ${message.createdBy?.username ?? 'Unknown'}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(Groupdetailcontroller controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              focusNode: messageFocusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          if (messageController.text.isNotEmpty)
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  List<String> memberIds = controller
                          .groupDetails.value?.members
                          ?.map((member) => member.groupId ?? "")
                          .where((id) => id.isNotEmpty)
                          .toList() ??
                      [];
                  print(memberIds);
                  sendMessage(revicerId: memberIds, controller: controller);
                }),
        ],
      ),
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
