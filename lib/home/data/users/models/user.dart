import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final List<String> followers;
  final String email;
  final String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.followers,
    required this.email,
    required this.phoneNumber,
  });

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'followers': followers,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // Create an User object from a Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      followers: (data['followers'] as List).cast<String>(),
      email: data['email'],
      phoneNumber: data['phoneNumber'],
    );
  }
}
