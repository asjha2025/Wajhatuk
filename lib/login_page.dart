import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wajhatuk/Admin/add_city.dart';
import 'package:wajhatuk/App_thime.dart';
import 'package:wajhatuk/register_page.dart';

import 'Admin/start_page.dart';
import 'LocalResident/accommodation.dart';
import 'LocalResident/accommodationshow.dart';
import 'LocalResident/start_LocalResident.dart';
import 'Tourest/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool showPassword = false; // For toggling password visibility

  // Show error dialog
  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text('Incorrect email or password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show password reset dialog
  void showForgotPasswordDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: emailController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Password reset email sent!'),
                    ));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error sending password reset email.'),
                    ));
                  }
                }
              },
              child: Text('Send'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: mainColor,)),
        centerTitle: true,
        backgroundColor: lastColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200,
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ),
            SizedBox(height: 40),
      TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email,color: lastColor,),
            ),
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
            SizedBox(height: 20),
      TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock,color: lastColor,),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,color: lastColor,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
              ),
              obscureText: !showPassword,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),

      Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showForgotPasswordDialog(context);
              },
              child: Text('Forgot Password?'),
            ),
          ),
            SizedBox(height: 20),
      ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                  await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  if (userCredential.user != null) {
                    // Fetch user type from Firestore
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user!.uid)
                        .get();

                    String userType = userDoc['userType'];

                    if (userType == 'localResident') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartLocalresidentPage(
                            userId: userDoc.id,
                            Username: userDoc['name'],
                          ),
                        ),
                      );
                    } else if (userType == 'tourist') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(userId: userDoc.id),
                        ),
                      );
                    } else if (userType == 'admin') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationsPage(
                            userId: userDoc.id,
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  showErrorDialog(context);
                }
              },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15), backgroundColor: lastColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Login', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor,)),
            ),
            SizedBox(height: 10),
            Center(child: Text("Don't have an account?",style: TextStyle(color: lastColor),)),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15), backgroundColor: lastColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text('Register', style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: mainColor,)),
        ),
          ],
        ),
      ),
    );
  }
}
