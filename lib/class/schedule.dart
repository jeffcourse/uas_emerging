class Schedule {
  int id;
  String date;
  String time;
  String location;
  String address;
  String gameName;
  int memberCount;
  int minPlayers;
  String userEmail;
  String gameUrl;
  int isCurrentUser;
  int isCreator;

  Schedule(
    {required this.id,
    required this.date,
    required this.time,
    required this.location,
    required this.address,
    required this.gameName, 
    required this.memberCount,
    required this.minPlayers,
    required this.userEmail,
    required this.gameUrl,
    required this.isCurrentUser,
    required this.isCreator}
  );

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      date: json['date'] as String, 
      time: json['time'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      gameName: json['game_name'] as String,
      memberCount: json['member_count'] as int,
      minPlayers: json['min_players'] as int,
      userEmail: json['user_email'] as String,
      gameUrl: json['game_url'] as String,
      isCurrentUser: json['is_current_user'] as int,
      isCreator: json['creator'] as int
      );
  }

  List<Schedule> SL = [];
}