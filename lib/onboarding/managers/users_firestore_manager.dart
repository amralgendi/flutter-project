import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersFirestoreManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save or update user data in Firestore
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save user data: $e");
    }
  }

  // Fetch user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception("Failed to fetch user data: $e");
    }
  }

  // Delete user data from Firestore
  Future<void> deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception("Failed to delete user data: $e");
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).update(userData);
    } catch (e) {
      throw Exception("Failed to update user data: $e");
    }
  }
}