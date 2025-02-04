import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Utils/SnackBar.dart';

import 'package:splitwise/ViewModel/Controller/GroupController.dart';

class GroupScreen extends StatefulWidget {
  final bool isUpdate;

  GroupScreen({required this.isUpdate});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController groupName = TextEditingController();
  final TextEditingController searchContact = TextEditingController();

  @override
  void dispose() {
    groupName.dispose();
    searchContact.dispose();

    super.dispose();
  }

  final GroupController groupController = Get.put(GroupController());
  @override
  void initState() {
    if (!widget.isUpdate) {
      groupController.clearContacts();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    "${groupController.selectedContacts.length}/1023",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                widget.isUpdate
                    ? SizedBox()
                    : TextField(
                        controller: groupName,
                        decoration: InputDecoration(hintText: "Group Name"),
                      ),
                SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: searchContact,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search name or number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (query) => groupController.filterContacts(query),
                ),
              ],
            ),
          ),
          // Selected Contacts
          Obx(() {
            return Wrap(
              spacing: 8,
              children: groupController.selectedContacts.map((contact) {
                return Chip(
                  label: Text(contact.displayName),
                  onDeleted: () {
                    groupController.selectedContacts.remove(contact);
                  },
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 10),
          // Contacts List
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: groupController.filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = groupController.filteredContacts[index];
                  final isSelected =
                      groupController.selectedContacts.contains(contact);

                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: contact.profilePicture != null
                            ? NetworkImage(contact.profilePicture!)
                            : null,
                        child: contact.profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(contact.displayName),
                      subtitle: Text(contact.phoneNumber),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) async {
                          if (value == true) {
                            try {
                              final message = await groupController
                                  .validateContact(contact, context);
                              // Show success message

                              showCustomSnackBar(context, "Added Contact");
                            } catch (error) {
                              // Show error message

                              showCustomSnackBar(context, error.toString());
                            }
                          } else {
                            groupController.selectedContacts.remove(contact);
                            // Show a message if desired

                            showCustomSnackBar(context,
                                "${contact.displayName} has been removed from the list.");
                          }
                        },
                      ));
                },
              );
            }),
          ),
          // Create Group Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Check group name validation only if `widget.isUpdate` is true
                if (!widget.isUpdate && groupName.text.trim().isEmpty) {
                  // Show a dialog box if the group name is empty
                  Get.dialog(
                    AlertDialog(
                      title: const Text("Input Required"),
                      content: const Text(
                          "Group name is required. Please enter a group name."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back(); // Close the dialog
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Handle create or update logic
                  if (widget.isUpdate) {
                    Get.back(); // Close the current screen if updating
                  } else {
                    await groupController.createGroup(
                        groupName.text.trim(), context);
                    Get.toNamed("/groupScreenList");
                  }
                }
              },
              child: Obx(() {
                return groupController.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.isUpdate ? "Add Member" : "Create Group");
              }),
            ),
          ),
        ],
      ),
    );
  }
}
