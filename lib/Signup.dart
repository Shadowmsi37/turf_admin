import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfadmin/Home.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController Name = TextEditingController();
  TextEditingController TurfName = TextEditingController();
  TextEditingController TurfRate = TextEditingController();
  TextEditingController TurfDistrict = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  final CollectionReference Admin = FirebaseFirestore.instance.collection('Admin');

  Future signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: Email.text.trim(),
          password: Password.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup Success'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();
      preferences.setBool('islogged', true);

      Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>Home()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup Failed $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
      Navigator.pop(context);

    }
  }

  Future add() async {
    final data = {
      "Name": Name.text,
      "TurfName": TurfName.text,
      "TurfRate": TurfRate.text,
      "TurfDistrict": TurfDistrict.text,
      "Email": Email.text,
      "Password": Password.text,
    };
    await Admin.add(data);
  }

  bool isNameValid(String value) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }

  bool isTurfRateValid(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  bool isEmailValid(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value);
  }

  bool isPasswordValid(String value) {
    return value.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(CupertinoIcons.back)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.blue,
              Colors.purple,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: Name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TurfName,
                    decoration: InputDecoration(
                      labelText: 'Turf Name',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TurfRate,
                    decoration: InputDecoration(
                      labelText: 'Turf Rate',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TurfDistrict,
                    decoration: InputDecoration(
                      labelText: 'Turf District',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: Email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: Password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.cyan),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.cyan.shade700),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                      ),
                      onPressed: () {
                        if (!isNameValid(Name.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter a valid Name (alphabets only)'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (!isNameValid(TurfName.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter a valid Turf Name (alphabets only)'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (!isTurfRateValid(TurfRate.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter a valid Turf Rate (numbers only)'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (!isNameValid(TurfDistrict.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter a valid Turf District (alphabets only)'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (!isEmailValid(Email.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please enter a valid email address'),
                            backgroundColor: Colors.red,
                          ));
                        } else if (!isPasswordValid(Password.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Password must be at least 6 characters long'),
                            backgroundColor: Colors.red,
                          ));
                        } else {
                          setState(() {
                            signup();
                            add();
                          });
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
