import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:splitwise/View/User/SelectContactScreen.dart';

class HomeScreenController extends GetxController {
  var selectedContacts = <Contact>[].obs;
  var groups = <List<Contact>>[].obs;

  // Fetch contacts from the device
  Future<void> fetchAndSelectContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final selected =
          await Get.to(() => SelectContactsScreen(contacts: contacts));
      if (selected != null && selected is List<Contact>) {
        selectedContacts.assignAll(selected);
      }
    } else {
      Get.snackbar("Permission Denied",
          "Contact access is required to select contacts.");
    }
  }

  // Add the selected contacts as a group
  void addGroup() {
    if (selectedContacts.isNotEmpty) {
      groups.add([...selectedContacts]);
      selectedContacts.clear();
    } else {
      Get.snackbar("No Contacts", "Please select at least one contact.");
    }
  }
}
