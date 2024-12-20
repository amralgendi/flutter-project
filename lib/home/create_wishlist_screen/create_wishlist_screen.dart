import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/data/wishlists/models/gift.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import 'package:uuid/uuid.dart';

import '../data/barcode_details.dart';

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

  Future<void> _scanBarcode() async {
    final Dio _dio = Dio();

    try {
      var result = await BarcodeScanner.scan();
      print(result.rawContent);

      final response = await _dio.get(
          "https://api.barcodelookup.com/v3/products?barcode=${result.rawContent}&formatted=y&key=nnbpuqi1qv0criduxsh7rm26zk1raw");

      if (response.statusCode == 200) {
        // Successfully fetched data
        setState(() {
          Map<String, dynamic> map = jsonDecode(response.data);

          BarcodeDetails details = BarcodeDetails.fromJson(map);

          GiftController scannedGiftController = GiftController();
          scannedGiftController.nameController.text = details.name;
          scannedGiftController.descriptionController.text =
              details.description;
          scannedGiftController.priceController.text = details.price.toString();
          scannedGiftController.selectedCategory =
              categories.any((c) => c == details.category)
                  ? details.category
                  : 'Electronics';

          setState(() {
            _giftControllers.add(scannedGiftController);
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode Product not Found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error Scanning the BarCode!')),
      );
    }
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
    final firestore = FirebaseFirestore.instance;
    final wishlistName = _wishlistNameController.text;

    try {
      final wishlistDoc = await firestore.collection("wishlists").add({
        "name": wishlistName,
        'userId': UserSessionManager.instance.getCurrentUser()!.uid
      });

      final gifts = _giftControllers.map((controller) {
        return Gift(
          id: const Uuid().v4(),
          userId: UserSessionManager.instance.getCurrentUser()!.uid,
          wishlistId: wishlistDoc.id,
          name: controller.nameController.text,
          imageBase64: controller.imageBase64,
          description: controller.descriptionController.text,
          price: double.tryParse(controller.priceController.text) ?? 0,
          category: controller.selectedCategory,
        );
      }).toList();

      final batch = firestore.batch();

      for (Gift gift in gifts) {
        DocumentReference ref = firestore.collection('gifts').doc();
        batch.set(ref, gift.toMap());
      }

      try {
        await batch.commit();

        await wishlistDoc.update({"giftCount": gifts.length});
      } catch (e) {
        await wishlistDoc.delete();
        rethrow;
      }

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
              ElevatedButton(
                onPressed: _scanBarcode,
                child: const Text('Scan Barcode for Gift'),
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
