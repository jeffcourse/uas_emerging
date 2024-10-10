import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emerging/class/chat.dart';
import 'package:uas_emerging/main.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class GameChat extends StatefulWidget {
  final int scheduleId;
  final String gameName;

  GameChat(this.scheduleId, this.gameName);

  @override
  State<StatefulWidget> createState() {
    return _GameChatState();
  }
}

class _GameChatState extends State<GameChat> {
  List<Chat> listChats = [];
  TextEditingController _chatInput = TextEditingController();

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/get_chats.php"),
        body: {
          'schedules_id': widget.scheduleId.toString(),
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void sendChat(chat) async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/new_chat.php"),
        body: {
          'user_email': activeUserEmail,
          'schedule_id': widget.scheduleId.toString(),
          'chat': chat
        });

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pesan telah dikirimkan')));
        readData();
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  readData() {
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);

      if (json['result'] == 'success') {
        for (var c in json['data']) {
          Chat chat = Chat.fromJson(c);
          setState(() {
            listChats.add(chat);
          });
        }
      }
    });
  }

  String chatSender(Chat chat) {
    if (chat.email == activeUserEmail) {
      return 'You';
    }

    return chat.name;
  }

  Widget chatList(List<Chat> chats) {
    log(chats.length.toString());
    if (chats != null) {
      return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (BuildContext ctxt, int index) {
            String time = DateFormat('dd/MM/yyyy HH:mm', 'id')
                .format(DateTime.parse(listChats[index].timestamp));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Card(
                  child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(chatSender(listChats[index])), Text(time)],
                ),
                subtitle: Text(listChats[index].chat),
              )),
            );
          });
    } else {
      return CircularProgressIndicator(
        value: 10.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Party Chat'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.gameName, style: TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: chatList(listChats),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatInput,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    sendChat(_chatInput.text);
                    _chatInput.text = "";
                    setState(() {
                      listChats = [];
                    });
                  },
                  child: Text('Kirim'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
