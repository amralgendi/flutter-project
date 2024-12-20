import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  final String id; // Adding the id field for Firestore document ID
  final String name;
  final String userId;
  final int giftCount;

  Wishlist({
    required this.id,
    required this.userId,
    required this.name,
    required this.giftCount,
  });

  // Convert Wishlist object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'giftCount': giftCount,
    };
  }

  // Create a Wishlist object from a Firestore document
  factory Wishlist.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Wishlist(
        id: doc.id, // Firestore assigns the document ID automatically
        name: data['name'],
        userId: data['userId'],
        giftCount: data["giftCount"]);
  }
}
