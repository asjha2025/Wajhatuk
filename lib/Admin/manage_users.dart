import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../App_thime.dart';

class AdminManagerPage extends StatefulWidget {
  @override
  _AdminManagerPageState createState() => _AdminManagerPageState();
}

class _AdminManagerPageState extends State<AdminManagerPage> {
  final TextEditingController _cityController = TextEditingController();
  String? _selectedCommand;
  List<String> _commands = ['Delete User', 'Block User', 'Update User Role'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: lastColor,
        title: Text('Admin Manager',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff)),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Manage Users
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final List<QueryDocumentSnapshot> userDocuments = snapshot.data!.docs;

                  if (userDocuments.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    itemCount: userDocuments.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> userData = userDocuments[index].data() as Map<String, dynamic>;
                      String userId = userDocuments[index].id;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text('User: ${userData['name']}'),
                          subtitle: Text('Email: ${userData['email']}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (command) => _handleCommand(userId, command),
                            itemBuilder: (context) {
                              return _commands.map((command) {
                                return PopupMenuItem<String>(
                                  value: command,
                                  child: Text(command),
                                );
                              }).toList();
                            },
                            child: Icon(Icons.more_vert),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Divider(height: 40),

            // Section 2: Add City



          ],
        ),
      ),
    );
  }

  // Add city to Firestore
  Future<void> _addCity() async {
    if (_cityController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Cities').add({
        'city_name': _cityController.text,
      });
      _cityController.clear(); // Clear the text field after adding
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a city name')),
      );
    }
  }

  // Handle admin commands (e.g., Delete, Block, Update Role)
  void _handleCommand(String userId, String command) async {
    if (command == 'Delete User') {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted')),
      );
    } else if (command == 'Block User') {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'status': 'blocked'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User blocked')),
      );
    } else if (command == 'Update User Role') {
      // Add your logic to update user role, e.g., admin, user, etc.
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': 'admin'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated')),
      );
    }
  }
}
