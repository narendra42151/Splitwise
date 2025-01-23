import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/CustomContact.dart';
import 'package:splitwise/Models/GroupModel.dart';
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

    // Set the initial group name
    nameController.text = widget.group.name ?? '';

    // Clear the existing selected contacts
    controller.selectedContacts.clear();

    // Populate selectedContacts with group members
    for (Members member in widget.group.members ?? []) {
      print(member.phoneNumber);
      var memberPhoneNumber =
          member.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';

      // Check if the member already exists in allContacts
      final existingContact = controller.allContacts.firstWhereOrNull(
        (contact) {
          var contactPhoneNumber =
              contact.phoneNumber.replaceAll(RegExp(r'\D'), '') ?? '';
          if (contactPhoneNumber.startsWith('91')) {
            contactPhoneNumber = contactPhoneNumber
                .substring(2); // Remove the first two characters
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Input Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 20),

            // Members List
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.selectedContacts.length,
                    itemBuilder: (context, index) {
                      final contact = controller.selectedContacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: contact.profilePicture != null &&
                                  contact.profilePicture!.isNotEmpty
                              ? NetworkImage(contact.profilePicture!)
                              : null,
                          child: contact.profilePicture == null
                              ? Icon(Icons.person)
                              : null,
                        ),
                        title: Text(contact.displayName),
                        subtitle: Text(contact.phoneNumber),
                      );
                    },
                  )),
            ),

            // Add Member Button
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/groupScreen');
              },
              icon: Icon(Icons.add),
              label: Text('Add Member'),
            ),
            const SizedBox(height: 20),

            // Save Changes Button
            ElevatedButton(
              onPressed: () async {
                // Update the group using selectedContacts and group name
                await controller.createGroup(nameController.text);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
