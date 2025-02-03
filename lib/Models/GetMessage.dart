import 'package:splitwise/Models/GroupModel.dart';

class MessageGet {
  String? messageId;
  String? message;
  Members? createdBy;
  String? groupId;
  String? createdAt;
  String? updatedAt;

  MessageGet({
    this.messageId,
    this.message,
    this.createdBy,
    this.groupId,
    this.createdAt,
    this.updatedAt,
  });

  MessageGet.fromJson(Map<String, dynamic> json) {
    messageId = json['_id'];
    message = json['message'];
    createdBy = json['createdBy'] != null
        ? new Members.fromJson(json['createdBy'])
        : null;
    groupId = json['groupId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.messageId;
    data['message'] = this.message;
    if (this.createdBy != null) {
      data['createdBy'] = this.createdBy!.toJson();
    }
    data['groupId'] = this.groupId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}
