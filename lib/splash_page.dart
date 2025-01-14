import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wajhatuk/Admin/Admin_home.dart';
import 'package:wajhatuk/Admin/add_city.dart';
import 'package:wajhatuk/Tourest/home_page.dart';
import 'package:wajhatuk/login_page.dart';
import 'package:wajhatuk/start_page.dart';

import 'Admin/manage_users.dart';
import 'Admin/start_page.dart';
import 'LocalResident/accommodationshow.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _loadWidegt();
  }

  _loadWidegt() {
    return Timer(Duration(seconds: 5), checkFirst);
  }

  Future checkFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen == false) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WajhatukStartPage()));
    } else {
      prefs.setBool('seen', true);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WajhatukStartPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/background_image.jpg', // Replace with your image asset path
            fit: BoxFit.cover,
          ),
          // Overlay text
        ],
      ),
    );

    // Your content goes here, for example, the logo or any other elements
    // Replace with your logo path
  }
}
