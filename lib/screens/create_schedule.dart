import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uas_emerging/class/game.dart';
import 'package:uas_emerging/main.dart';
import 'package:intl/date_symbol_data_local.dart';

class CreateSchedule extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateScheduleState();
  }
}

class _CreateScheduleState extends State<CreateSchedule> {
  final _formKey = GlobalKey<FormState>();

  final _controllerDate = TextEditingController();
  final _controllerTime = TextEditingController();
  final _controllerMinPlayers = TextEditingController();

  String _location = "";
  String _address = "";
  String _password = "";
  String _passwordRepeat = "";
  Game? _gameDropdownValue;

  List<Game> listGames = <Game>[];

  TimeOfDay _time =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  Future<String> fetchGames() async {
    final response = await http
        .get(Uri.parse("https://ubaya.me/flutter/160420011/uas/get_games.php"));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  readGames() {
    Future<String> data = fetchGames();
    data.then((value) {
      Map json = jsonDecode(value);
      if (json['result'] == 'success') {
        for (var g in json['data']) {
          Game game = Game.fromJson(g);
          setState(() {
            listGames.add(game);
          });
        }
      }
    });
  }

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
        _controllerTime.text = _time.format(context);
      });
    }
  }

  void submit() async {
    if(_controllerDate.text == "" || _controllerTime.text == "" || _location == "" || _address == "" || 
    _gameDropdownValue!.id.toString() == "" || _controllerMinPlayers.text == ""){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Seluruh isian tidak boleh kosong')));
    }else{
      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/new_schedule.php"),
        body: {
          'user_email': activeUserEmail,
          'date': _controllerDate.text,
          'time': _controllerTime.text,
          'location': _location,
          'address': _address,
          'game_id': _gameDropdownValue!.id.toString(),
          'min_players': _controllerMinPlayers.text
        });
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses membuat jadwal')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
      } else {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
        throw Exception('Failed to read API');
      }
    }
  }

  bool checkPassword() {
    if (_password != _passwordRepeat) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    readGames();
    initializeDateFormatting('id', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Buat Jadwal'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(children: [
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(width:450,child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tanggal',
                        ),
                        controller: _controllerDate,
                      )),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2200),
                          );

                          if (pickedDate != null) {
                          String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(pickedDate);
                          setState(() {
                            _controllerDate.text = formattedDate;
                          });
                          }
                        },
                          child: Icon(
                            Icons.calendar_today_sharp,
                            size: 24.0,
                          ))
                    ],
                  ))),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(width:450,child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Selected Time',
                        ),
                        controller: _controllerTime,
                      )),
                      ElevatedButton(
                          onPressed: () {
                            _selectTime();
                          },
                          child: Icon(
                            Icons.access_time,
                            size: 24.0,
                          ))
                    ],
                  ))),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width:450,child:TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Lokasi Dolan',
                      hintText: 'contoh: McDonalds, Starbucks'),
                  onChanged: (value) {
                    _location = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width:450,child:TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Alamat Dolan',
                      hintText: 'Masukkan alamat dolan'),
                  onChanged: (value) {
                    _address = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter valid Email';
                    }
                    return null;
                  },
                ),
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width:450,
                  child: DropdownButton<Game>(
                    isExpanded: true,
                    hint: Text('Pilih Game'),
                    value: _gameDropdownValue,
                    items: listGames.map((Game value) {
                    return DropdownMenuItem<Game>(
                      value: value,
                      child: Text(value.gameName),
                    );
                    }).toList(),
                    onChanged: (Game? value) {
                      setState(() {
                        _gameDropdownValue = value!;
                        _controllerMinPlayers.text = value.minPlayers.toString();
                      });
                    },
                  ),
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width:450,child:TextFormField(
                  readOnly: true,
                  controller: _controllerMinPlayers,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Minimal Member',
                      ),
                ),
              )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            !_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Harap Isian diperbaiki')));
                        } else {
                          submit();
                        }
                      },
                      child: Text(
                        'Buat Jadwal',
                        style: TextStyle( fontSize: 18),
                      ),
                    ),
                  )),
            ]),
          ),
        ));
  }
}
