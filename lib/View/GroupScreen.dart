import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:splitwise/ViewModel/Controller/GroupController.dart';

class GroupScreen extends StatelessWidget {
  final GroupController groupController = Get.put(GroupController());

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
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search name or number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                // Implement search filter logic if required
              },
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
                itemCount: groupController.allContacts.length,
                itemBuilder: (context, index) {
                  final contact = groupController.allContacts[index];
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
                      onChanged: (value) {
                        if (value == true) {
                          groupController.validateContact(contact);
                        } else {
                          groupController.selectedContacts.remove(contact);
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
          // Create Group Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: groupController.createGroup,
              child: const Text("Create Group"),
            ),
          ),
        ],
      ),
    );
  }
}
