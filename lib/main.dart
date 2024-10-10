import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emerging/class/member.dart';
import 'screens/login.dart';
import 'screens/schedule.dart';
import 'screens/search.dart';
import 'screens/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String activeUser = "";
String activeUserEmail = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_email = prefs.getString("user_email") ?? '';
  activeUser = prefs.getString("user_name") ?? '';
  return user_email;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      activeUserEmail = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DolanYuk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DolanYuk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _screens = [MySchedule(), Search(), Profile()];
  int _currentIdx = 0;
  Member _currentUser = Member(userEmail: "", name: "", photoUrl: "", isCurrentUser: 1);

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user_email");
    prefs.remove("user_name");
    main();
  }


  void changeScreen(int screenIdx) {
    setState(() {
      _currentIdx = screenIdx;
    });
    Navigator.pop(context);
  }

  Future<Member> getUser() async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160420011/uas/get_user.php"),
      body: {'email': activeUserEmail},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        return Member(
          userEmail: json['data'][0]['email'],
          name: json['data'][0]['name'],
          photoUrl: json['data'][0]['photo_url'],
          isCurrentUser: 1,
        );
      } else {
        throw Exception('Failed to load profile data');
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      setState(() {
        _currentUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: myDrawer(),
      body: _screens[_currentIdx],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIdx,
          fixedColor: Colors.teal,
          items: [
            BottomNavigationBarItem(
              label: "Jadwal",
              icon: Icon(Icons.calendar_month),
            ),
            BottomNavigationBarItem(
              label: "Cari",
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: "Profil",
              icon: Icon(Icons.person),
            ),
          ],
          onTap: (int index) {
            setState(() {
              _currentIdx = index;
            });
          },
        )
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: Text(activeUser),
              accountEmail: Text(activeUserEmail),
              decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://picsum.photos/1280/600/?blur=2'), scale: 1.5, colorFilter: ColorFilter.mode(Colors.grey.shade800, BlendMode.hardLight))),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(_currentUser.photoUrl))),
          ListTile(
              title: new Text("Jadwal"),
              leading: new Icon(Icons.calendar_month),
              onTap: () {
                changeScreen(0);
              }),
          ListTile(
              title: Text("Cari"),
              leading: Icon(Icons.search),
              onTap: () {
                changeScreen(1);
              }),
          ListTile(
              title: Text("Profil"),
              leading: Icon(Icons.person),
              onTap: () {
                changeScreen(2);
              }),
          ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () {
                doLogout();
              }),
        ],
      ),
    );
  }
}
