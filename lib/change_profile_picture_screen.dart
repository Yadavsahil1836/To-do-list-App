import 'package:flutter/material.dart';

class ChangeProfilePictureScreen extends StatefulWidget {
  const ChangeProfilePictureScreen({super.key});

  @override
  State<ChangeProfilePictureScreen> createState() => _ChangeProfilePictureScreenState();
}

class _ChangeProfilePictureScreenState extends State<ChangeProfilePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Change Profile Picture', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage('images/profile.jpg'), // Replace with your image
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Action to change profile picture
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Change Profile Picture'),
          ),
        ],
      ),
    );
  }
}
