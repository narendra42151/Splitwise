import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/TestScreen.dart';
import 'package:splitwise/View/Group/GroupDetails.dart';
import 'package:splitwise/View/Group/GroupScreen.dart';
import 'package:splitwise/ViewModel/Controller/GroupController.dart';

class GroupListScreen extends StatefulWidget {
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final GroupController groupController = Get.put(GroupController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      groupController.fetchUserGroups(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        leading: IconButton(
          onPressed: () {
            if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
              Get.offNamed("/home"); // Safely navigating
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Future.delayed(Duration.zero, () {
                Get.to(() => GroupScreen(isUpdate: false));
              });
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: groupController.searchGroups,
              decoration: InputDecoration(
                labelText: "Search Groups",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (groupController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (groupController.filteredGroups.isEmpty) {
                return const Center(child: Text("No groups found."));
              }
              return ListView.builder(
                itemCount: groupController.filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = groupController.filteredGroups[index];
                  return ListTile(
                    leading: CircleAvatar(child: const Icon(Icons.group)),
                    title: Text(group.name ?? "Unnamed Group"),
                    subtitle: Text(
                        "Created by: ${group.createdBy?.username ?? 'Unknown'}"),
                    trailing: IconButton(
                      onPressed: () {
                        Future.delayed(Duration.zero, () {
                          Get.to(() => TestScreen(group: group));
                        });
                      },
                      icon: Icon(Icons.edit),
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        Get.to(() => GroupDetailsScreen(
                              groupId: group.groupId ?? "",
                            ));
                      });
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
