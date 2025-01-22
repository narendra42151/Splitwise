class GroupModel {
  String? groupId;
  String? name;
  CreatedBy? createdBy; // Update type from String? to CreatedBy?
  List<Members>? members;
  List<String>? expenses; // Use dynamic for flexibility
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
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy']) // Parse createdBy as an object
        : null;
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
    expenses = json['expenses'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = groupId;
    data['name'] = name;
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    data['expenses'] = this.expenses;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CreatedBy {
  String? id;
  String? username;

  CreatedBy({this.id, this.username});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['username'] = username;
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

// class GroupModel {
//   String? groupId;
//   String? name;
//   CreatedBy? createdBy; // Update type from String? to CreatedBy?
//   List<Members>? members;
//   List<dynamic>? expenses; // Use dynamic for flexibility
//   String? createdAt;
//   String? updatedAt;

//   GroupModel({
//     this.groupId,
//     this.name,
//     this.createdBy,
//     this.members,
//     this.expenses,
//     this.createdAt,
//     this.updatedAt,
//   });

//   GroupModel.fromJson(Map<String, dynamic> json) {
//     groupId = json['_id'];
//     name = json['name'];
//     createdBy = json['createdBy'] != null
//         ? CreatedBy.fromJson(json['createdBy']) // Parse createdBy as an object
//         : null;
//     if (json['members'] != null) {
//       members = <Members>[];
//       json['members'].forEach((v) {
//         members!.add(Members.fromJson(v));
//       });
//     }
//     expenses = json['expenses'] ?? [];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = groupId;
//     data['name'] = name;
//     if (createdBy != null) {
//       data['createdBy'] = createdBy!.toJson();
//     }
//     if (members != null) {
//       data['members'] = members!.map((v) => v.toJson()).toList();
//     }
//     data['expenses'] = expenses;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     return data;
//   }
// }

// class CreatedBy {
//   String? id;
//   String? username;

//   CreatedBy({this.id, this.username});

//   CreatedBy.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     username = json['username'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = id;
//     data['username'] = username;
//     return data;
//   }
// }

// class Members {
//   String? groupId;
//   String? username;
//   String? profilePicture;
//   String? phoneNumber;

//   Members({this.groupId, this.username, this.profilePicture, this.phoneNumber});

//   Members.fromJson(Map<String, dynamic> json) {
//     groupId = json['_id'];
//     username = json['username'];
//     profilePicture = json['profilePicture'];
//     phoneNumber = json['phoneNumber'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.groupId;
//     data['username'] = this.username;
//     data['profilePicture'] = this.profilePicture;
//     data['phoneNumber'] = this.phoneNumber;
//     return data;
//   }
// }
