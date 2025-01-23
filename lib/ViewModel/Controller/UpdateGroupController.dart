import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/GroupModel.dart';
import 'package:splitwise/Repositry/GroupRepositry.dart';

class GroupUpdateController extends GetxController {
  final GroupUpdateRepository groupRepository;

  GroupUpdateController({required this.groupRepository});

  final nameController = TextEditingController();
  var members = <Members>[].obs;
  var groupId = "".obs;

  void initializeGroup(GroupModel group) {
    nameController.text = group.name ?? "";
    groupId.value = group.groupId ?? "";
    members.value = group.members ?? [];
  }

  void addMember(Members member) {
    members.add(member);
  }

  void removeMember(Members member) {
    members.remove(member);
  }

  Future<void> updateGroup() async {
    try {
      final data = {
        "name": nameController.text,
        "members": members.map((m) => m.groupId).toList(),
      };
      await groupRepository.updateGroup(groupId.value, data);
      Get.snackbar('Success', 'Group updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update group');
    }
  }
}
