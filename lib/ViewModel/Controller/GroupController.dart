import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  RxList<CustomContact> allContacts = <CustomContact>[].obs;
  RxList<CustomContact> selectedContacts = <CustomContact>[].obs;

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
    final isInDatabase = await checkContactInDatabase(contact.phoneNumber);
    if (isInDatabase) {
      selectedContacts.add(contact);
    } else {
      Get.snackbar(
        "Contact Not Found",
        "${contact.displayName} is not registered.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> checkContactInDatabase(String phoneNumber) async {
    // Simulate API call for validation
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return phoneNumber.endsWith('5'); // Example validation logic
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
