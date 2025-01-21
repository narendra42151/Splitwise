import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:splitwise/Repositry/Group.repositry.dart';

class GroupController extends GetxController {
  RxList<CustomContact> allContacts = <CustomContact>[].obs;
  RxList<CustomContact> selectedContacts = <CustomContact>[].obs;
  final GroupRepository _repository = GroupRepository();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  @override
  void onInit() {
    super.onInit();
    fetchAllContacts(); // Fetch contacts when the controller initializes
  }

  Future<void> fetchAllContacts() async {
    try {
      // Request permission to access contacts
      if (await FlutterContacts.requestPermission()) {
        // Fetch all contacts using flutter_contacts
        final List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, // Include phone numbers and emails
          withPhoto: true, // Include profile pictures
        );

        // Map the contacts into our custom CustomContact model
        allContacts.value = contacts
            .map((Contact contact) => CustomContact(
                  displayName: contact.displayName,
                  phoneNumber: contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : "No Number",
                  profilePicture: contact.photo != null
                      ? String.fromCharCodes(contact.photo!)
                      : null,
                ))
            .toList();
      } else {
        // Show a message if permission is denied
        Get.snackbar(
          "Permission Denied",
          "Contacts access is required to fetch contacts.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load contacts: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> validateContact(CustomContact contact) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Remove all non-numeric characters from the phone number
      var phoneNumber = contact.phoneNumber.replaceAll(RegExp(r'\D'), '');
      print(phoneNumber);

      // Check if the contact is in the database
      final isInDatabase =
          await _repository.checkContactInDatabase(phoneNumber);

      if (isInDatabase) {
        selectedContacts.add(contact);

        // Show success message
        Get.snackbar(
          "Contact Added",
          "${contact.displayName} has been added to the list.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Show error message
        Get.snackbar(
          "Contact Not Found",
          "${contact.displayName} is not registered.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        "Error",
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void createGroup() {
    if (selectedContacts.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one contact to create a group.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Your logic for creating a group can go here
      Get.snackbar(
        "Success",
        "Group created successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class CustomContact {
  final String displayName;
  final String phoneNumber;
  final String? profilePicture;

  CustomContact({
    required this.displayName,
    required this.phoneNumber,
    this.profilePicture,
  });
}
