import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/data/wishlists/models/wishlist.dart';
import 'dart:math';

import 'package:hedieaty/home/friend_details/wishlist_screen/wishlist_screen.dart';

import '../data/users/models/user.dart';

class FriendDetailsScreen extends StatelessWidget {
  final User user;
  FriendDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("wishlists")
              .where("userId", isEqualTo: user.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No wishlists found.'),
              );
            }

            List<Wishlist> wishlists = snapshot.data!.docs
                .map((doc) => Wishlist.fromDocument(doc))
                .toList();
            return CustomScrollView(
              slivers: [
                // Friend's Profile
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Picture
                        const CircleAvatar(
                          radius: 40,
                          child: Icon(Icons.person,
                              size: 40), // Placeholder profile picture
                        ),
                        SizedBox(width: 16),
                        // Friend's Name
                        Text(
                          user.name, // Replace with dynamic name
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Wishlist Grid
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to wishlist details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WishlistScreen(
                                  wishlist: wishlists[index], user: user),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3, // Slight elevation for subtle shadow
                          shadowColor: Colors.black
                              .withOpacity(0.5), // Subtle shadow color
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize
                                .min, // Prevents overflow by making column take minimal height
                            children: [
                              // Wishlist Header (Full-width colored section)
                              Container(
                                width: double.infinity,
                                height:
                                    120, // Fixed height for the colored header
                                decoration: BoxDecoration(
                                  color:
                                      _getRandomColor(), // Random color for the header
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                              ),
                              // Wishlist Content
                              Expanded(
                                child: SingleChildScrollView(
                                  // Added scrolling capability for content
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Wishlist Name
                                        Text(
                                          wishlists[index]
                                              .name, // Replace with dynamic list name
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Number of Gift Items
                                        Text(
                                          '${wishlists[index].giftCount} Items', // Replace with dynamic item count
                                          style: TextStyle(color: Colors.grey),
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
                    childCount:
                        wishlists.length, // Example count of wishlist items
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Corrected function to generate a random color
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
