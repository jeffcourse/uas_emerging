import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _userEmail = "";
  String _password = "";
  String _passwordRepeat = "";

  void submit() async {
    final response = await http
        .post(Uri.parse("https://ubaya.me/flutter/160420011/uas/signup.php"), body: {
      'email': _userEmail,
      'name': _name,
      'password': _password,
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Registrasi. Silahkan Login')));
        Navigator.pop(context);
      }else if(json['result'] == 'fail'){
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Email sudah teregistrasi')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
    }
  }

  bool checkPassword() {
    if (_password != _passwordRepeat) return false;
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      hintText: 'Enter your name'),
                  onChanged: (value) {
                    _name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email id as abc@gmail.com'),
                  onChanged: (value) {
                    _userEmail = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter valid Email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password'),
                  onChanged: (value) {
                    _password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    return null;
                  }
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Repeat Password',
                      hintText: 'Repeat entered password'),
                  onChanged: (value) {
                    _passwordRepeat = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Repeated password cannot be empty';
                    }
                    return null;
                  }
                ),
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
                          if (checkPassword()) {
                            submit();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Passwords do not match!')));
                          }
                        }
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
