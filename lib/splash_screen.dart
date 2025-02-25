import 'package:flutter/material.dart';
import 'Home_screen.dart';
import 'dart:async';



class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(
        seconds: 2
      ),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  HomeScreen()))  ;
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        child: Container(
          child: const Text('Task Manager App..'
          ,style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
        ),
      ),
    );
  }
}
