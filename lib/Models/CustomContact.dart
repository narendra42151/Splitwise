class CustomContact {
  final String displayName;
  final String phoneNumber;
  final String? profilePicture;
  final String? userId; // Add userId field

  CustomContact({
    required this.displayName,
    required this.phoneNumber,
    this.profilePicture,
    this.userId,
  });
}
