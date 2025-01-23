import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/CustomContact.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/View/Group/GroupScreen.dart';
import 'package:splitwise/ViewModel/Controller/GroupController.dart';

class TestScreen extends StatefulWidget {
  final GroupModel group;
  TestScreen({required this.group, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final GroupController controller = Get.find<GroupController>();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Delay the updates to reactive state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set the initial group name
      nameController.text = widget.group.name ?? '';

      // Clear the existing selected contacts
      controller.selectedContacts.clear();

      // Populate selectedContacts with group members
      for (Members member in widget.group.members ?? []) {
        var memberPhoneNumber =
            member.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';

        // Check if the member already exists in allContacts
        final existingContact = controller.allContacts.firstWhereOrNull(
          (contact) {
            var contactPhoneNumber =
                contact.phoneNumber.replaceAll(RegExp(r'\D'), '');
            if (contactPhoneNumber.startsWith('91')) {
              contactPhoneNumber = contactPhoneNumber.substring(2);
            }
            return contactPhoneNumber == memberPhoneNumber;
          },
        );

        if (existingContact != null) {
          // If member exists, add to selectedContacts
          controller.selectedContacts.add(existingContact);
        } else {
          // If member doesn't exist in contacts, add a custom contact
          controller.selectedContacts.add(CustomContact(
            displayName: member.username ?? '',
            phoneNumber: member.phoneNumber ?? '',
            profilePicture: member.profilePicture,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Input Field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 20),

            // Members List
            Expanded(
              child: Obx(() {
                final selectedContacts = controller.selectedContacts;
                return ListView.builder(
                  itemCount: selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = selectedContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: contact.profilePicture != null &&
                                contact.profilePicture!.isNotEmpty
                            ? NetworkImage(contact.profilePicture!)
                            : null,
                        child: contact.profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(contact.displayName),
                      subtitle: Text(contact.phoneNumber),
                    );
                  },
                );
              }),
            ),

            // Add Member Button
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => GroupScreen(
                      isUpdate: true,
                    ));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Member'),
            ),
            const SizedBox(height: 20),

            // Save Changes Button
            Obx(() {
              final isLoading = controller.isLoading.value;
              return ElevatedButton(
                onPressed: isLoading
                    ? null // Disable button when loading
                    : () async {
                        await controller.updateGroup(
                            nameController.text, widget.group.groupId ?? "");
                        Get.toNamed("/home");
                      },
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Save Changes'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
