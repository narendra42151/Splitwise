import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

import 'package:splitwise/ViewModel/Controller/HomeController.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final AuthController authController = Get.find<AuthController>();
  final HomeScreenController homeController = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(themeController.isDarkMode.value
                  ? Icons.dark_mode
                  : Icons.light_mode),
              onPressed: themeController.toggleTheme,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // CircleAvatar(
                  //   radius: 30,
                  //   backgroundImage:
                  //       authController.user.value?.profilePicture != null
                  //           ? NetworkImage(
                  //               authController.user.value!.profilePicture!)
                  //           : null,
                  //   child: authController.user.value?.profilePicture == null
                  //       ? const Icon(Icons.person, size: 30)
                  //       : null,
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authController.user.value!.username ?? "Username",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "View and update your profile",
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.toNamed('/profile/edit');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Update Password
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Update Password"),
              subtitle: const Text("Change your account password"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.toNamed('/updatePassword');
              },
            ),
            const SizedBox(height: 20),

            // Contact Selection Section
            Text(
              "Select Contacts for Group",
              // style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            Obx(
              () => homeController.selectedContacts.isEmpty
                  ? const Text("No contacts selected.")
                  : Wrap(
                      spacing: 8,
                      children: homeController.selectedContacts
                          .map((contact) => Chip(
                                label: Text(contact.displayName),
                                onDeleted: () {
                                  homeController.selectedContacts
                                      .remove(contact);
                                },
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: homeController.fetchAndSelectContacts,
              icon: const Icon(Icons.contacts),
              label: const Text("Select Contacts"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: homeController.addGroup,
              child: const Text("Create Group"),
            ),
            const SizedBox(height: 20),

            // Groups Section
            Text(
              "Groups",
              // style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            Obx(
              () => homeController.groups.isEmpty
                  ? const Text("No groups created yet.")
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: homeController.groups.length,
                        itemBuilder: (context, index) {
                          final group = homeController.groups[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text("Group #${index + 1}"),
                              subtitle: Text(
                                group
                                    .map((contact) => contact.displayName)
                                    .join(", "),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
