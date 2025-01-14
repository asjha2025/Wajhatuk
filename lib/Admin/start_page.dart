import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../App_thime.dart';
import 'acommont_management.dart';
import 'add_city.dart';
import 'admin_profile.dart';
import 'manage_users.dart';

class DestinationsPage extends StatefulWidget {
  final String userId;
  DestinationsPage({required this.userId});
  @override
  _DestinationsPageState createState() => _DestinationsPageState();
}

class _DestinationsPageState extends State<DestinationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,

      appBar: AppBar(
        backgroundColor: lastColor, // Match color theme from your design

        title: Text('Admin Mangament', style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor),
        textAlign: TextAlign.center,),
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
                    Expanded(child:_buildAdminButton('Accounts Management', Icons.account_circle,AdminManagerPage())),
                    SizedBox(width: 6.0),
                    Expanded(child: _buildAdminButton('Admin ProFile', Icons.person,ProfilePage(userId:widget.userId))),

                  ],
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child:_buildAdminButton('Comments management', Icons.comment,CommentsManagerPage())),
                    SizedBox(width: 6.0),

                    Expanded(child:                                                   _buildAdminButton('Cities Management', Icons.location_city,AddCity(userId:widget.userId))),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(String label, IconData icon,Page_name) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Page_name));

        // Handle button actions (e.g., manage accounts, reports, or comments)
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Button color to match the theme
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
