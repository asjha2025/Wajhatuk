import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wajhatuk/App_thime.dart';
import 'package:wajhatuk/Tourest/home_page.dart';
import 'package:wajhatuk/login_page.dart';

import 'Admin/add_city.dart';
import 'Admin/start_page.dart';
import 'LocalResident/accommodation.dart';
import 'LocalResident/accommodationshow.dart';
import 'LocalResident/start_LocalResident.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String userType = 'localResident'; // Default user type
  bool showPassword = false; // For toggling password visibility

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text('Register', style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: mainColor,)),
        centerTitle: true,
        backgroundColor: lastColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Adding form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    width: 200.0,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person,color: lastColor,),
                  ),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
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
                  obscureText: !showPassword, // Toggle password visibility
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                  obscureText: !showPassword, // Toggle password visibility
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: userType,
                  onChanged: (String? newValue) {
                    setState(() {
                      userType = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'User Type',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['localResident', 'tourist','admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Perform registration
                      try {
                        UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);
                        if (userCredential.user != null) {
                          await _firestore
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .set({
                            'name': name,
                            'email': email,
                            'userType': userType, // Use class-level userType here
                          });

                          // Navigate based on userType
                          DocumentSnapshot userDoc =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .get();

                          String fetchedUserType = userDoc['userType'];

                          if (fetchedUserType == 'localResident') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartLocalresidentPage(
                                  userId: userDoc.id,
                                  Username: userDoc['name'],
                                ),
                              ),
                            );
                          } else if (fetchedUserType == 'tourist') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  userId: userDoc.id,
                                ),
                              ),
                            );
                          } else if (fetchedUserType == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DestinationsPage(userId: userDoc.id),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print(e);
                      }
                    }
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
        ),
      ),
    );
  }
}
