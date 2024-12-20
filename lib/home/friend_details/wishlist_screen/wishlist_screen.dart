import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/data/wishlists/models/gift.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import 'dart:math';

import '../../data/users/models/user.dart';
import '../../data/wishlists/models/wishlist.dart';

class WishlistScreen extends StatefulWidget {
  final Wishlist wishlist;
  final User user;

  WishlistScreen({super.key, required this.wishlist, required this.user});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wishlist Name
            Text(
              widget.wishlist.name, // Replace with dynamic list name
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            // Number of Items
            Text(
              '${widget.wishlist.giftCount} Items', // Replace with dynamic item count
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("gifts")
                .where("wishlistId", isEqualTo: widget.wishlist.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No gifts found.'),
                );
              }

              print(snapshot.data!.docs.length);

              List<Gift> gifts = snapshot.data!.docs
                  .map((doc) => Gift.FromDocument(doc))
                  .toList();

              return CustomScrollView(
                slivers: [
                  // Gift Items Grid
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (gifts[index].pledgedBy != null) return;
                            _showPledgeBottomSheet(context, gifts[index]);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3, // Subtle shadow for each card
                            shadowColor: Colors.black
                                .withOpacity(0.2), // Subtle shadow color
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize
                                  .min, // Prevent overflow by making column take minimal height
                              children: [
                                // Gift Item Image
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color:
                                        _getRandomColor(), // Random color for placeholder image
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .card_giftcard, // Placeholder gift icon
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                // Gift Item Content
                                Expanded(
                                  child: SingleChildScrollView(
                                    // Added scrolling for content inside the card
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Gift Item Name
                                          Text(
                                            "${gifts[index].name}${gifts[index].pledgedBy != null ? "\t PLEDGED" : ""}", // Replace with dynamic item name
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Gift Item Price
                                          Text(
                                            '\$${gifts[index].price}', // Replace with dynamic price
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: gifts.length, // Example count of gift items
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  // Function to show the bottom sheet asking if the user wants to pledge
  void _showPledgeBottomSheet(BuildContext context, Gift gift) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Would you like to pledge to get this gift?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pledge to buy this gift for the user.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Action when the user chooses to pledge

                      final updatedGift = Gift(
                          category: gift.category,
                          description: gift.description,
                          id: gift.id,
                          name: gift.name,
                          price: gift.price,
                          userId: gift.userId,
                          wishlistId: gift.wishlistId,
                          imageBase64: gift.imageBase64,
                          pledgedBy: UserSessionManager.instance
                              .getCurrentUser()!
                              .uid);

                      await FirebaseFirestore.instance
                          .collection("gifts")
                          .doc(updatedGift.id)
                          .update(updatedGift.toMap());

                      Navigator.pop(context);
                      _showConfirmationDialog(context);
                    },
                    child: const Text('Pledge'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Action when the user chooses not to pledge
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show a confirmation dialog after pledging
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pledge Successful'),
          content:
              const Text('You have pledged to get this gift for the user.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Corrected function to generate a random color for placeholder image
  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Alpha channel (opacity)
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }
}
