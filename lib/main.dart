import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfadmin/Home.dart';
import 'package:turfadmin/Login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    getloggedData().whenComplete((){
      if(finalData == true){
        Navigator.push(context, MaterialPageRoute(builder:(context)=>
            Home()));
      }else{
        Future.delayed(Duration(seconds: 4),(){
          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Login()));
        });
      }
    });
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

bool ? finalData;
Future getloggedData() async{
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  var getData = preferences.getBool('islogged');
  setState(() {
    finalData = getData;

    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset('lib/Images/Startapp.png'),
        ),
      ),
    );
  }
}
