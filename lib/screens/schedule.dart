import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emerging/class/member.dart';
import 'package:uas_emerging/main.dart';
import 'dart:convert';
import 'package:uas_emerging/screens/create_schedule.dart';
import 'package:uas_emerging/class/schedule.dart';
import 'dart:developer';

import 'package:uas_emerging/screens/game_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySchedule extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyScheduleState();
  }
}

class _MyScheduleState extends State<MySchedule> {
  List<Schedule> sl = [];

  List<Member> _listMembers = [];

  bool _listEmpty = false;

  Future<String> fetchData(email) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.me/flutter/160420011/uas/get_user_schedules.php"),
        body: {'email': email});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  readData(email) {
    Future<String> data = fetchData(email);
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

  readMembersData(id) {
    fetchMembers(id, activeUserEmail).then((value) {
      Map json = jsonDecode(value);
      if (json['result'] == 'success') {
        for (var m in json['data']) {
          Member member = Member.fromJson(m);
          setState(() {
            _listMembers.add(member);
          });
        }

        return ListView.builder(
          itemCount: _listMembers.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return memberName(_listMembers[index]);
          },
        );
      }
    });
  }

  Widget memberList(List<Member> members) {
    if (_listMembers.isNotEmpty) {
      return ListView.builder(
        itemCount: members.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  title: memberName(members[index]),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget memberName(Member member) {
    if (member.isCurrentUser == 0) {
      return Text(member.name);
    }

    return Text("${member.name} (You)");
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
      ),
    );
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
      lw.add(
        Card(
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
        )
      );
    }

    return lw;
  }

  String joinCount(Schedule schedule) {
    int min = schedule.minPlayers;
    int member = schedule.memberCount;

    return '$member/$min';
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sukses hapus jadwal')));
        setState(() {
          sl.clear();
          readData('');
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget generateButton(Schedule schedule) {
      if (schedule.isCreator == 1) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 2, backgroundColor:Colors.red.shade600),
              onPressed: () {
                deleteSchedule(schedule.id);
              },
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton.icon(
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
            )
          ],
        );
      }
      return Row(
          mainAxisAlignment: MainAxisAlignment.end,
        children:[ElevatedButton.icon(
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
      )]);
  }

  Widget scheduleList(List<Schedule> schedules) {
    if (schedules != null) {
      return ListView.builder(
          shrinkWrap: true,
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
                              child: generateButton(schedules[index]))
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
          children: [Text('Jadwal main masih kosong nih'), Text('Cari konco main atau bikin jadwal baru aja')],
        ),
      );
    }

    return ListView(children: <Widget>[
      Container(
        height: MediaQuery.of(context).size.height - 125,
        child: scheduleList(sl),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    readData(activeUserEmail);
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
        body: generateBody());
  }
}
