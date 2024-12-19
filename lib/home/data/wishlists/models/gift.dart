class Gift {
  final String id;  // Unique identifier for each gift
  final String name;
  final String? imageBase64;
  final String description;
  final double price;
  final String category;

  Gift({
    required this.id,
    required this.name,
    this.imageBase64,
    required this.description,
    required this.price,
    required this.category,
  });

  // Convert Gift object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,  // Include the gift ID in the map
      'name': name,
      'imageBase64': imageBase64,
      'description': description,
      'price': price,
      'category': category,
    };
  }

  // Create a Gift object from a Map (subdocument in Wishlist)
  factory Gift.fromMap(Map<String, dynamic> data) {
    return Gift(
      id: data['id'],  // Pass the ID as part of the object creation
      name: data['name'],
      imageBase64: data['imageBase64'],
      description: data['description'],
      price: data['price'],
      category: data['category'],
    );
  }
}