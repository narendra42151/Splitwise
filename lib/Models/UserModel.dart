class UserModel {
  String? userId;
  String? username;
  String? profilePicture;
  String? phoneNumber;
  List<String>? joinedGroups;
  String? createdAt;
  String? updatedAt;

  UserModel({
    this.userId,
    this.username,
    this.profilePicture,
    this.phoneNumber,
    this.joinedGroups,
    this.createdAt,
    this.updatedAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['_id'];
    username = json['username'];
    profilePicture = json['profilePicture'];
    phoneNumber = json['phoneNumber'];
    joinedGroups = json['joinedGroups'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.userId;
    data['username'] = this.username;
    data['profilePicture'] = this.profilePicture;
    data['phoneNumber'] = this.phoneNumber;
    data['joinedGroups'] = this.joinedGroups;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}
