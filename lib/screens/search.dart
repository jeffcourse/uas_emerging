import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emerging/main.dart';
import 'dart:convert';
import 'package:uas_emerging/class/schedule.dart';
import 'package:uas_emerging/screens/create_schedule.dart';
import 'package:uas_emerging/class/member.dart';

import 'package:uas_emerging/screens/game_chat.dart';

class Search extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<Search> {
  List<Schedule> sl = [];
  bool _listEmpty = false;

  Future<String> fetchData(search) async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/get_schedules.php"),
        body: {'email': activeUserEmail, 'search': search});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  readData(search) {
    Future<String> data = fetchData(search);
    data.then((value) {
      Map json = jsonDecode(value);
      if (json['result'] == 'success') {
        for (var s in json['data']) {
          Schedule sc = Schedule.fromJson(s);
          setState(() {
            sl.add(sc);
          });
        }
      } else {
        setState(() {
          _listEmpty = true;
        });
      }
    });
  }

  void joinSchedule(id) async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/new_member.php"),
        body: {'user_email': activeUserEmail, 'schedule_id': id.toString()});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sukses bergabung dengan jadwal')));
        main();
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<String> fetchMembers(id, email) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.me/flutter/160420011/uas/get_schedule_members.php"),
        body: {'email': activeUserEmail, 'schedules_id': id.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget memberName(Member member) {
    if (member.isCurrentUser == 0) {
      return Text(member.name);
    }

    return Text("${member.name} (You)");
  }

  List<Widget> parseMembersData(String data) {
    Map json = jsonDecode(data);
    List<Member> members = [];
    List<Widget> lw = [];

    if (json['result'] == 'success') {
      for (var m in json['data']) {
        Member member = Member.fromJson(m);
        members.add(member);
      }
    }

    for (var m in members) {
      lw.add(Card(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(m.photoUrl),
                radius: 30,
              ),
            ),
            memberName(m)
          ],
        ),
      ));
    }

    return lw;
  }

  void showMembers(Schedule schedule) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Konco Dolanan'),
              content: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    Text('Member bergabung: ${joinCount(schedule)}'),
                    Expanded(
                      child: FutureBuilder(
                        future: fetchMembers(schedule.id, activeUserEmail),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error loading members'),
                            );
                          } else {
                            return Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: parseMembersData(snapshot.data!),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Keren!'),
                ),
              ],
            ));
  }

  String joinCount(Schedule schedule) {
    int min = schedule.minPlayers;
    int member = schedule.memberCount;

    return '$member/$min';
  }

  Widget generateChatButton(Schedule schedule) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(elevation: 2),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    GameChat(schedule.id, schedule.gameName)));
      },
      label: Text('Party Chat'),
      icon: Icon(Icons.chat),
    );
  }

  Widget generateCardButtons(Schedule schedule) {
    if (schedule.isCurrentUser == 1) {
      if (schedule.isCreator == 1) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 2, backgroundColor: Colors.red.shade600),
              onPressed: () {
                deleteSchedule(schedule.id);
              },
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
            generateChatButton(schedule)
          ],
        );
      }
      return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [generateChatButton(schedule)]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(elevation: 2),
        onPressed: () {
          if (schedule.memberCount == schedule.minPlayers) {
            ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Jadwal main sudah penuh!')));
          } else {
            joinSchedule(schedule.id);
          }
        },
        label: Text('Join'),
        icon: Icon(
          Icons.input,
          size: 23,
        ),
      )
    ]);
  }

  Widget scheduleList(List<Schedule> schedules) {
    if (schedules != null) {
      return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.network(
                      schedules[index].gameUrl,
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ),
                  ListTile(
                    title: Text(schedules[index].gameName),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedules[index].date,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                          Text(
                            schedules[index].time,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                                onPressed: () {
                                  showMembers(schedules[index]);
                                },
                                icon: Icon(Icons.local_taxi),
                                label: Text(
                                    "${joinCount(schedules[index])} orang")),
                          ),
                          Text(
                            schedules[index].location,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                          Text(
                            schedules[index].address,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: generateCardButtons(schedules[index]))
                        ]),
                  ),
                ],
              ),
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget generateBody() {
    if (_listEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tidak ada schedule tercatat.'),
            Text('Buatlah schedule baru')
          ],
        ),
      );
    }

    return Expanded(
      child: ListView(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height - 200,
          child: scheduleList(sl),
        ),
      ]),
    );
  }

  void deleteSchedule(id) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.me/flutter/160420011/uas/delete_schedules.php"),
        body: {'schedule_id': id.toString()});

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses hapus jadwal')));
        setState(() {
          sl.clear();
          readData('');
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    super.initState();
    readData('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateSchedule()));
          },
          tooltip: 'Create',
          child: const Icon(Icons.edit),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        hintText: 'Search',
                      ),
                      onChanged: (search) {
                        setState(() {
                          if (search.isEmpty) {
                            readData('');
                            return;
                          } else {
                            sl.clear();
                            readData(search);
                            return;
                          }
                        });
                      },
                      onSubmitted: (search) {
                        fetchData(search);
                      },
                    ),
                  ),
                ],
              ),
            ),
            generateBody(),
          ],
        ));
  }
}
