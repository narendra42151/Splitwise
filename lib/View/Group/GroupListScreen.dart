import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/View/Group/GroupDetails.dart';
import 'package:splitwise/ViewModel/Controller/GroupController.dart';

class GroupListScreen extends StatelessWidget {
  final GroupController groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    // Fetch groups when the screen loads
    groupController.fetchUserGroups();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: Column(
        children: [
          // Search bar
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

          // Group list
          Expanded(
            child: Obx(() {
              // Show loading spinner
              if (groupController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show message if no groups found
              if (groupController.filteredGroups.isEmpty) {
                return const Center(child: Text("No groups found."));
              }

              // Display group list
              return ListView.builder(
                itemCount: groupController.filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = groupController.filteredGroups[index];
                  return ListTile(
                    leading: CircleAvatar(
                      // backgroundImage: group.members!.isNotEmpty &&
                      //         group.members!.first.profilePicture != null
                      //     ? NetworkImage(group.members!.first.profilePicture!)
                      //     : null,
                      child: const Icon(Icons.group),
                    ),
                    title: Text(group.name ?? "Unnamed Group"),
                    subtitle:
                        Text("Created by: ${group.createdBy ?? 'Unknown'}"),
                    onTap: () {
                      Get.to(() => GroupDetailsScreen(
                            groupId: group.groupId ?? "",
                          ));
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