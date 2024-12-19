import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/data/wishlists/models/gift.dart';
import 'package:uuid/uuid.dart';

class CreateNewWishlistScreen extends StatefulWidget {
  const CreateNewWishlistScreen({super.key});

  @override
  _CreateNewWishlistScreenState createState() =>
      _CreateNewWishlistScreenState();
}

class _CreateNewWishlistScreenState extends State<CreateNewWishlistScreen> {
  final _wishlistNameController = TextEditingController();
  final List<GiftController> _giftControllers = [];

  final List<String> categories = [
    'Electronics',
    'Books',
    'Toys',
    'Clothing',
    'Home Decor',
    'Sports',
    'Other',
  ];

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
                // TODO: ADD IMAGE
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

  // Function to create the wishlist
  void _createWishlist() async {
    final wishlistName = _wishlistNameController.text;
    final gifts = _giftControllers.map((controller) {
      return Gift(
        id: const Uuid().v4(),
        name: controller.nameController.text,
        imageBase64: controller.imageBase64,
        description: controller.descriptionController.text,
        price: double.tryParse(controller.priceController.text) ?? 0,
        category: controller.selectedCategory,
      );
    }).toList();

    try {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wishlist Created Successfully!')),
      );
      // Dismiss the screen after success
      Navigator.pop(context);
    } catch (e) {
      // Show error message if wishlist creation fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Wishlist'),
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
                'Add Gifts to Wishlist',
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
              // Create Wishlist Button
              ElevatedButton(
                onPressed: _createWishlist,
                child: const Text('Create Wishlist'),
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
}
