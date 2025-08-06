//welcome screen contains login info,google sign in ,app name

//importing the packages to perform functions

import 'package:flutter/material.dart';
import 'package:zippyit/repositary/screens/bottomnav/bottomnavscreen.dart';
import 'package:zippyit/repositary/widgets/uihelper.dart';

import '../../auth_helper.dart';
import '../../signupscreen.dart';

class Welcomescreen extends StatelessWidget {
  const Welcomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  //decoration of  the container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/bg11.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App Icon
                Container(
                  //we can give height and widgth
                  height: 80,
                  width: 80,
                  //container box decoration
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipOval(
                      child: Uihelper.CustomImage(img: "profiledp.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 8),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Uihelper.CustomText(
                    text: "Everything You Need, Just a Click Away.",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Uihelper.CustomText(
                          text: "Fast. Fresh. Yours.",
                          color: Colors.red.shade700,
                          fontweight: FontWeight.bold,
                          fontsize: 20,
                        ),
                        const SizedBox(height: 6),
                        Uihelper.CustomText(
                          text:
                              "Groceries, gadgets & more — delivered at lightning speed! ⚡",
                          color: Colors.green.shade700,
                          fontweight: FontWeight.bold,
                          fontsize: 13,
                        ),

                        const SizedBox(height: 24),

                        // Google sig in button inside the  button
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              final user = await AuthHelper.signInWithGoogle();
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Bottomnavscreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Google Sign-In failed')),
                                );
                              }
                            },
                            //outline button
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Uihelper.CustomImage(img: "google.webp"),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign Up Text
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: Uihelper.CustomText(
                            text: "Don't have an account? Sign up",
                            color: Colors.indigo,
                            fontweight: FontWeight.w500,
                            fontsize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
