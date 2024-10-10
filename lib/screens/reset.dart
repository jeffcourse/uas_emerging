import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uas_emerging/main.dart';

class Reset extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResetState();
  }
}

class _ResetState extends State<Reset> {
  final _formKey = GlobalKey<FormState>();

  String _oldPassword = "";
  String _password = "";
  String _passwordRepeat = "";

  bool isPasswordSame(newPass, newPassConfirm) {
    if (newPass == newPassConfirm) return true;
    return false;
  }

  void resetPassword(oldPass, newPass, newPassConfirm) async {
    if (!isPasswordSame(newPass, newPassConfirm)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password baru tidak sama!')));
      return;
    }

    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420011/uas/reset.php"),
        body: {
          'email': activeUserEmail,
          'old_pass': oldPass,
          'new_pass': newPass,
        });

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password berhasil diubah')));
        Navigator.pop(context);
      } else if (json['result'] == 'fail_auth') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password lama tidak sesuai')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('API Error')));
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
          title: Text('Reset Password'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(width:450,child:TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Old Password',
                      hintText: 'Enter old password'),
                  onChanged: (value) {
                    _oldPassword = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Old password cannot be empty';
                    }
                    return null;
                  },
                ),
              )),
              Padding(
                padding: EdgeInsets.all(10),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(width:450,child:TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'New Password',
                        hintText: 'Enter secure password'),
                    onChanged: (value) {
                      _password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      return null;
                    }),
              )),
              Padding(
                padding: EdgeInsets.all(10),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(width:450,child:TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Repeat New Password',
                        hintText: 'Repeat entered password'),
                    onChanged: (value) {
                      _passwordRepeat = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Repeated password cannot be empty';
                      }
                      return null;
                    }),
              )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 300,
                    
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red.shade600)),
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            !_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Harap Isian diperbaiki')));
                        } else {
                          resetPassword(_oldPassword, _password, _passwordRepeat);
                        }
                      },
                      child: Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )),
            ]),
          ),
        ));
  }
}
