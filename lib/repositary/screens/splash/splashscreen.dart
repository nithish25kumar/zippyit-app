import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippyit/repositary/screens/bottomnav/bottomnavscreen.dart';
import 'package:zippyit/repositary/screens/welcomescreen.dart';

import '../../widgets/uihelper.dart';

//stateful widget becoz it can navigate to another screen in few sec
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      //if user has logged in he can navigate to the homescreen
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Bottomnavscreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Welcomescreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bg color
      backgroundColor: Colors.red,
      //aligning to center
      body: Center(
        //child->column->children
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Uihelper.CustomImage(img: "food_delivery.png"),
            SizedBox(
              height: 5,
            ),
            Uihelper.CustomText(
              text: "ZippyIt!",
              color: Colors.black,
              fontweight: FontWeight.bold,
              fontsize: 40,
              fontfamily: "bold",
            ),
          ],
        ),
      ),
    );
  }
}
