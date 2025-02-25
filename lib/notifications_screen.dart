import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Notification 1',
                  maxLines: 2,  // Allows long text to wrap and be fully displayed
                  overflow: TextOverflow.ellipsis,  // Shows ellipsis if the text is too long
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Details about notification 1'),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Notification 2',
                  maxLines: 2,  // Allows long text to wrap and be fully displayed
                  overflow: TextOverflow.ellipsis,  // Shows ellipsis if the text is too long
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Details about notification 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
