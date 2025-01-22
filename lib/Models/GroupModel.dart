class GroupModel {
  String? groupId;
  String? name;
  String? createdBy;
  List<Members>? members;
  List<Null>? expenses;
  String? createdAt;
  String? updatedAt;

  GroupModel({
    this.groupId,
    this.name,
    this.createdBy,
    this.members,
    this.expenses,
    this.createdAt,
    this.updatedAt,
  });

  GroupModel.fromJson(Map<String, dynamic> json) {
    groupId = json['_id'];
    name = json['name'];
    createdBy = json['createdBy'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
    expenses = [];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.groupId;
    data['name'] = this.name;
    data['createdBy'] = this.createdBy;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    if (this.expenses != null) {
      data['expenses'] = this.expenses;
    }

    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}

class Members {
  String? groupId;
  String? username;
  String? profilePicture;
  String? phoneNumber;

  Members({this.groupId, this.username, this.profilePicture, this.phoneNumber});

  Members.fromJson(Map<String, dynamic> json) {
    groupId = json['_id'];
    username = json['username'];
    profilePicture = json['profilePicture'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.groupId;
    data['username'] = this.username;
    data['profilePicture'] = this.profilePicture;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
