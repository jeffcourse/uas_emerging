class Member {
  String userEmail;
  String name;
  String photoUrl;
  dynamic isCurrentUser;

  Member({
    required this.userEmail,
    required this.name,
    required this.photoUrl,
    required this.isCurrentUser,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userEmail: json['users_email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      isCurrentUser: json['is_current_user']);
  }
}