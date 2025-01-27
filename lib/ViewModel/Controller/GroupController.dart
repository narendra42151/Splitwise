import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/CustomContact.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Repositry/Group.repositry.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

class GroupController extends GetxController {
  RxList<CustomContact> allContacts = <CustomContact>[].obs;
  RxList<CustomContact> selectedContacts = <CustomContact>[].obs;
  RxList<CustomContact> filteredContacts = <CustomContact>[].obs;
  final GroupRepository _repository = GroupRepository();
  final RxBool isLoading = false.obs;
  RxList<GroupModel> allGroups = <GroupModel>[].obs;
  RxList<GroupModel> filteredGroups = <GroupModel>[].obs;

  final RxString error = ''.obs;
  final AuthController authController = Get.find<AuthController>();

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

        // Initially, filteredContacts will contain all contacts
        filteredContacts.value = allContacts;
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

  void filterContacts(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all contacts
      filteredContacts.value = allContacts;
    } else {
      // Filter contacts based on display name or phone number
      filteredContacts.value = allContacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()) ||
              contact.phoneNumber.contains(query))
          .toList();
    }
  }

  Future<void> validateContact(CustomContact contact) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Remove all non-numeric characters from the phone number
      var phoneNumber = contact.phoneNumber.replaceAll(RegExp(r'\D'), '');

      if (phoneNumber.startsWith('91')) {
        phoneNumber =
            phoneNumber.substring(2); // Remove the first two characters
      }

      // Check if the contact is in the database
      final response = await _repository.checkContactInDatabase(phoneNumber);
      print(response);

      final exists = response['exists'];
      final userId = response['userId'];

      if (exists) {
        // Create a new contact with the userId
        final updatedContact = CustomContact(
          displayName: contact.displayName,
          phoneNumber: contact.phoneNumber,
          profilePicture: contact.profilePicture,
          userId: userId, // Include the userId
        );

        selectedContacts.add(updatedContact);

        // Return success status
        return Future.value("Contact Added: ${contact.displayName}");
      } else {
        // Return error status
        return Future.error("${contact.displayName} is not registered.");
      }
    } catch (e) {
      error.value = e.toString();
      return Future.error("Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void clearContacts() {
    selectedContacts.clear();
  }

  Future<void> fetchUserGroups() async {
    try {
      isLoading.value = true;

      final response = await _repository.getUserGroups();

      // Parse the response into a list of GroupModel objects
      final groups = response
          .map<GroupModel>((json) => GroupModel.fromJson(json))
          .toList();

      // Update reactive lists
      allGroups.value = groups;
      filteredGroups.value = groups; // Initially, display all groups
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        "Error",
        "Failed to fetch user groups: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchGroups(String query) {
    if (query.isEmpty) {
      filteredGroups.value = allGroups; // Reset to all groups
    } else {
      filteredGroups.value = allGroups
          .where((group) =>
              group.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> createGroup(String groupName) async {
    if (selectedContacts.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one contact to create a group.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.createGroup(
          groupName, selectedContacts, authController.user.value!.userId ?? "");
      if (response != null) {
        Get.snackbar(
          "Success",
          "Group created successfully!",
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchUserGroups();
        clearContacts();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create group: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup(String groupName, String groupId) async {
    isLoading.value = true;
    if (selectedContacts.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one contact to create a group.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.updateGroupDetails(
          groupId, groupName, selectedContacts);
      if (response != null) {
        await fetchUserGroups();
        Get.snackbar(
          "Success",
          "Group Updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {}
      clearContacts();
      Get.snackbar(
        "Group",
        "Group Updated",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create group: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
