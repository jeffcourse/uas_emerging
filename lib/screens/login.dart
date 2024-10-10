import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emerging/main.dart';
import 'package:uas_emerging/screens/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String _userEmail = "";
  String _password = "";

  void doLogin() async {
    final response = await http
        .post(Uri.parse("https://ubaya.me/flutter/160420011/uas/login.php"), body: {
      'email': _userEmail,
      'password': _password,
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Login')));

        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_email", _userEmail);
        prefs.setString("user_name", json['name']);
        main();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Invalid Credentials')));
      } 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('API Error')));
      throw Exception('Error: API Error');
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width: 400, child:TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email id as abc@gmail.com'),
                  onChanged: (value) {
                    _userEmail = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  }
                )),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width: 400, child:TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Masukkan Password'),
                  onChanged: (value) {
                    _password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  }
                )),
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            !_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Harap Isian diperbaiki')));
                        } else {
                          doLogin();
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )),
            ]),
          ),
        ));
  }
}
