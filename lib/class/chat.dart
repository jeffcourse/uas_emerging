class Chat {
  int id;
  String email;
  String chat;
  String timestamp;
  String name;
  String photoUrl;

  Chat({
    required this.id,
    required this.email,
    required this.chat,
    required this.timestamp,
    required this.name,
    required this.photoUrl
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'], email: json['users_email'], chat: json['chat'], timestamp: json['timestamp'], name: json['name'], photoUrl: json['photo_url']);
  }
}