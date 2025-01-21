import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SelectContactsScreen extends StatefulWidget {
  final List<Contact> contacts;

  const SelectContactsScreen({required this.contacts, Key? key})
      : super(key: key);

  @override
  _SelectContactsScreenState createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  final List<Contact> selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.pop(context, selectedContacts);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.contacts.length,
        itemBuilder: (context, index) {
          final contact = widget.contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(contact.displayName[0]),
            ),
            title: Text(contact.displayName),
            trailing: Checkbox(
              value: selectedContacts.contains(contact),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected == true) {
                    selectedContacts.add(contact);
                  } else {
                    selectedContacts.remove(contact);
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}
