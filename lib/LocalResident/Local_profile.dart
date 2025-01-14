import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../App_thime.dart';

class LocalProfilePage extends StatefulWidget {
  final String userId;

  LocalProfilePage({required this.userId});

  @override
  _LocalProfilePageState createState() => _LocalProfilePageState();
}

class _LocalProfilePageState extends State<LocalProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _passwordController.text = userData['password'] ?? ''; // Usually store hashed
      });
    }
  }

  Future<void> _updateUserProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Setting',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor),),
        backgroundColor: lastColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with user image if available
              ),
              SizedBox(height: 20),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),

              // Family Name Field

              SizedBox(height: 10),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10),

              // Phone Field

              SizedBox(height: 10),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 10),

              // Bio Field

              SizedBox(height: 20),

              // Update Button
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Update', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainColor),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lastColor, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
