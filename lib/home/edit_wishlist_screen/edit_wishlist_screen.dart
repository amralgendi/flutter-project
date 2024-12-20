import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty/home/data/wishlists/models/gift.dart';
import 'package:hedieaty/home/data/wishlists/models/wishlist.dart';
import 'package:uuid/uuid.dart';

class EditWishlistScreen extends StatefulWidget {
  final Wishlist wishlist;

  const EditWishlistScreen({super.key, required this.wishlist});

  @override
  _EditWishlistScreenState createState() => _EditWishlistScreenState();
}

class _EditWishlistScreenState extends State<EditWishlistScreen> {
  final _wishlistNameController = TextEditingController();
  final _giftControllers = <GiftController>[];
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    'Electronics',
    'Books',
    'Toys',
    'Clothing',
    'Home Decor',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the controllers based on the existing wishlist
    _wishlistNameController.text = widget.wishlist.name;
    _loadGifts();
  }

  void _loadGifts() async {
    var giftDocs = await FirebaseFirestore.instance
        .collection("gifts")
        .where("wishlistId", isEqualTo: widget.wishlist.id)
        .get();

    print(giftDocs.docs.length);

    for (var doc in giftDocs.docs) {
      _giftControllers.add(GiftController.fromGift(Gift.FromDocument(doc)));
    }
    setState(() {});
  }

  // Function to add a new gift field
  void _addGift() {
    setState(() {
      _giftControllers.add(GiftController());
    });
  }

  // Function to remove a gift field
  void _removeGift(int index) {
    setState(() {
      _giftControllers.removeAt(index);
    });
  }

  // Function to create a gift widget
  Widget _buildGiftForm(int index) {
    final giftController = _giftControllers[index];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gift ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            // Gift Name
            TextField(
              controller: giftController.nameController,
              decoration: const InputDecoration(
                labelText: 'Gift Name',
              ),
            ),
            const SizedBox(height: 8),
            // Gift Image Upload
            GestureDetector(
              onTap: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final bytes = await File(pickedFile.path).readAsBytes();
                  final base64Image = base64Encode(bytes);
                  setState(() {
                    giftController.imageBase64 = base64Image;
                  });
                }
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: giftController.imageBase64 == null
                    ? const Center(child: Text('Tap to upload image'))
                    : Image.memory(
                        base64Decode(giftController.imageBase64!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Gift Description
            TextField(
              controller: giftController.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Gift Description',
              ),
            ),
            const SizedBox(height: 8),
            // Gift Price
            TextField(
              controller: giftController.priceController,
              decoration: const InputDecoration(
                labelText: 'Gift Price',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            // Gift Category Dropdown
            DropdownButtonFormField<String>(
              value: giftController.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Gift Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  giftController.selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 8),
            // Remove Gift Button
            if (_giftControllers.length > 1)
              TextButton(
                onPressed: () => _removeGift(index),
                child: const Text('Remove Gift'),
              ),
          ],
        ),
      ),
    );
  }

  // Function to update the wishlist
  void _updateWishlist() async {
    final wishlistName = _wishlistNameController.text;

    if (wishlistName.isEmpty || _giftControllers.isEmpty) {
      // Show error if wishlist name or gifts are not filled
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Please provide a wishlist name and at least one gift.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final alreadyExistingGifts = await FirebaseFirestore.instance
        .collection("gifts")
        .where("wishlistId", isEqualTo: widget.wishlist.id)
        .get();

    // Process the updated wishlist and gifts
    final gifts = _giftControllers.map((controller) {
      return Gift(
        id: const Uuid().v4(),
        userId: UserSessionManager.instance.getCurrentUser()!.uid,
        wishlistId: widget.wishlist.id,
        name: controller.nameController.text,
        imageBase64: controller.imageBase64,
        description: controller.descriptionController.text,
        price: double.tryParse(controller.priceController.text) ?? 0,
        category: controller.selectedCategory,
      );
    }).toList();

    final addBatch = FirebaseFirestore.instance.batch();

    DocumentReference ref =
        FirebaseFirestore.instance.collection('gifts').doc();
    for (Gift gift in gifts) {
      addBatch.set(ref, gift.toMap());
    }

    await addBatch.commit();

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(widget.wishlist.id)
        .update({
      "giftCount": gifts.length,
      "name": _wishlistNameController.text.trim()
    });

    WriteBatch deleteBatch = FirebaseFirestore.instance.batch();
    for (var doc in alreadyExistingGifts.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist Updated Successfully!')),
    );

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wishlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _wishlistNameController,
                decoration: const InputDecoration(
                  labelText: 'Wishlist Name',
                ),
              ),
              const SizedBox(height: 16),
              // Gifts Section
              const Text(
                'Edit Gifts in Wishlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              // Dynamically generated gift forms
              for (int i = 0; i < _giftControllers.length; i++)
                _buildGiftForm(i),
              const SizedBox(height: 16),
              // Add New Gift Button
              ElevatedButton(
                onPressed: _addGift,
                child: const Text('Add New Gift'),
              ),
              const SizedBox(height: 16),
              // Update Wishlist Button
              ElevatedButton(
                onPressed: _updateWishlist,
                child: const Text('Update Wishlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GiftController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? imageBase64;
  String selectedCategory = 'Electronics'; // Default category

  GiftController();

  GiftController.fromGift(Gift gift) {
    nameController.text = gift.name;
    descriptionController.text = gift.description;
    priceController.text = gift.price.toString();
    imageBase64 = gift.imageBase64;
    selectedCategory = gift.category;
  }
}
