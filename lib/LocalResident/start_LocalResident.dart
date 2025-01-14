import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Admin/admin_profile.dart';
import '../App_thime.dart';
import 'accommodationshow.dart';
import 'acommont_management.dart';

class StartLocalresidentPage extends StatefulWidget {
  final String userId;
  final String Username;
  StartLocalresidentPage({required this.userId, required this.Username});

  @override
  _StartLocalresidentPageState createState() => _StartLocalresidentPageState();
}

class _StartLocalresidentPageState extends State<StartLocalresidentPage> {
  @override
  void initState() {
    super.initState();
    _showWelcomeDialog();
  }

  void _showWelcomeDialog() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(

        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: lastColor,
            title: Text('Welcome, ${widget.Username}!', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
              textAlign: TextAlign.center,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('To WAJHATUK.' ,style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),

                textAlign: TextAlign.center,),
                SizedBox(height: 16.0),

                Text('You can add your Accommodatins with ease.' ,style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
                  textAlign: TextAlign.center,),
                SizedBox(height: 16.0),

                Text("Let's get started." ,style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
                  textAlign: TextAlign.center,),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Strat', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
                  textAlign: TextAlign.center,),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text(
          'Local Resident Management',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Flexible(
              child: Hero(
                tag: 'logo',
                child: Expanded(
                  child: Container(
                    height: 600.0,
                    width: 300,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
              ),
            ),
          ),
          // Admin Section with buttons
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 6.0),
                  ],
                ),
                SizedBox(height: 30.0),
                _buildAdminButton(
                  'Profiles management',
                  Icons.person,
                  ProfilePage(userId: widget.userId),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildAdminButton(
                        'Comments management',
                        Icons.comment,
                        AccommodationManagerPage(userId:widget.userId),
                      ),
                    ),
                    SizedBox(width: 6.0),
                    Expanded(
                      child: _buildAdminButton(
                        'Accommodation Management',
                        Icons.house,
                        AccommodationListPage(
                          userId: widget.userId,
                          Username: widget.Username,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(String label, IconData icon, Widget pageName) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pageName),
        );
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
