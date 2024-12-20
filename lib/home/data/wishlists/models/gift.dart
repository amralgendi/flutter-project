import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id; // Unique identifier for each gift
  final String userId; // Unique identifier for each gift
  final String wishlistId; // Unique identifier for each gift
  final String name;
  final String? imageBase64;
  final String description;
  final double price;
  final String category;

  Gift({
    required this.id,
    required this.userId,
    required this.wishlistId,
    required this.name,
    this.imageBase64,
    required this.description,
    required this.price,
    required this.category,
  });

  // Convert Gift object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'wishlistId': wishlistId,
      'imageBase64': imageBase64,
      'description': description,
      'price': price,
      'category': category,
    };
  }

  // Create a Gift object from a Map
  factory Gift.FromDocument(DocumentSnapshot data) {
    return Gift(
      id: data.id,
      name: data['name'],
      userId: data['userId'],
      wishlistId: data['wishlistId'],
      imageBase64: data['imageBase64'],
      description: data['description'],
      price: data['price'],
      category: data['category'],
    );
  }
}
