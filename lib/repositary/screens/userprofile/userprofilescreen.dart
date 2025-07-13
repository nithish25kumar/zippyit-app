import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _launchLinkedIn() async {
    const url =
        'https://www.linkedin.com/in/nithish-kumar-9b29b3287?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 28),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user!.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: Colors.white,
                        child: user!.photoURL == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user!.displayName ?? "Guest",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "User Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      user!.email ?? "Not Available",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.red),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        user!.displayName ?? 'No Name Available',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(thickness: 1.5),
                const SizedBox(height: 10),
                const Text(
                  "Creator Info",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/nithish1.jpeg'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Nithish Kumar .K',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Reg No: 23MIS0311',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        'Vellore Institute of Technology, Vellore',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _launchLinkedIn,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.link, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'LinkedIn Profile',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
