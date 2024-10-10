class Game {
  int id;
  String gameName;
  int minPlayers;
  String gameUrl;

  Game({
    required this.id,
    required this.gameName,
    required this.minPlayers,
    required this.gameUrl
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(id: json['id'], gameName: json['game_name'], minPlayers: json['min_players'], gameUrl: json['game_url']);
  }
}