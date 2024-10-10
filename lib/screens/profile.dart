import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:uas_emerging/class/member.dart';
import 'package:uas_emerging/main.dart';
import 'package:uas_emerging/screens/reset.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  late Future<Member> _memberFuture;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _photoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _memberFuture = _fetchProfileData();
  }

  Future<Member> _fetchProfileData() async {
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

  Future<String> updateProfile(
      String email, String name, String profileUrl) async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160420011/uas/update_profile.php"),
      body: {'name': name, 'photo_url': profileUrl, 'email': email},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses update profil')));
        setState(() {
          _memberFuture = _fetchProfileData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update profil gagal. Silahkan dicoba kembali')));
      }
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Member>(
          future: _memberFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Member currentMember = snapshot.data!;
              _nameController.text = currentMember.name;
              _emailController.text = currentMember.userEmail;
              if(currentMember.photoUrl == "https://static.thenounproject.com/png/4851855-200.png"){
                _photoController.text = "";
              }else{
                _photoController.text = currentMember.photoUrl;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 35),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(currentMember.photoUrl),
                      radius: 80,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(width:450,child:TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          hintText: 'Masukkan Nama'),
                      controller: _nameController,
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(width:450,child:TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Masukkan Email'),
                      controller: _emailController,
                      readOnly: true,
                      enabled: false,
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(width:450,child:TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Photo URL',
                          hintText: 'Masukkan Photo URL'),
                      controller: _photoController,
                    ),
                  )),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                    padding: const EdgeInsets.all(25),
                    child: ElevatedButton(
                        onPressed: () {
                          updateProfile(currentMember.userEmail,
                              _nameController.text, _photoController.text);
                        },
                        child: Text('Update Profil')
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red.shade600)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Reset()));
                        },
                        child: Text('Reset Password',style: TextStyle(color: Colors.white),)
                    ),
                  ),
                  ],
              )]);
            }
          },
        ),
      ),
    );
  }
}
