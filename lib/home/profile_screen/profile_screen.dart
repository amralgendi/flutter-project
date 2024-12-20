import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/my_pledged_gifts_screen/my_pledged_gifts_screen.dart';
import 'package:hedieaty/home/profile_settings_screen/profile_settings_screen.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import 'package:hedieaty/onboarding/welcome_screen.dart';

import '../data/users/models/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy data for username
  String userId = UserSessionManager.instance.getCurrentUser()!.uid;

  // Method to show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await UserSessionManager.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.data == null) {
                return const Center(
                  child: Text('No wishlists found.'),
                );
              }

              User user = User.fromDocument(snapshot.data!);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Profile Image Placeholder
                          ClipOval(
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors
                                  .grey[300], // Placeholder background color
                              child: const Icon(
                                Icons.account_circle,
                                size: 80,
                                color: Colors.white, // White color for the icon
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Username
                          Text(
                            user.name, // Use the dummy username
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.phoneNumber, // Use the dummy username
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions List
                  Expanded(
                    child: ListView(
                      children: [
                        // Settings Button
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        // My Pledged Gifts Button
                        ListTile(
                          leading: const Icon(Icons.card_giftcard),
                          title: const Text('My Pledged Gifts'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MyPledgedGiftsScreen(),
                              ),
                            );
                          },
                        ),
                        // Logout Button
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap:
                              _showLogoutDialog, // Show the logout confirmation dialog
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
