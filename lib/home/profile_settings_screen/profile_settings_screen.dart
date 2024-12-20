import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/users/models/user.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final User user;
  const ProfileSettingsScreen({super.key, required this.user});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize with default values or fetch from a data source
    _nameController.text =
        widget.user.name; // Example placeholder for the user's name
  }

  void _saveSettings() async {
    // Save updated settings
    final updatedName = _nameController.text;
    final notificationsEnabled = _notificationsEnabled;

    User updatedUser = User(
        email: widget.user.email,
        followers: widget.user.followers,
        id: widget.user.id,
        name: updatedName,
        phoneNumber: widget.user.phoneNumber);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.id)
        .update(updatedUser.toMap());

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings Saved Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Management Section
            const Text(
              'Profile Management',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Notification Settings Section
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Toggle
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
