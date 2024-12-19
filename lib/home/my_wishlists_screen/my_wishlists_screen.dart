import 'dart:math';

import 'package:flutter/material.dart';
import '../create_wishlist_screen/create_wishlist_screen.dart';
import '../data/wishlists/models/gift.dart';
import '../data/wishlists/models/wishlist.dart';
import '../edit_wishlist_screen/edit_wishlist_screen.dart';

class MyWishlistScreen extends StatelessWidget {
  MyWishlistScreen({super.key});

  List<Wishlist> wishlists = [
    Wishlist(
      id: 'wishlist1',
      name: 'Birthday Wishlist',
      gifts: [
        Gift(
          id: 'gift1',
          name: 'Wireless Headphones',
          imageBase64: null,
          description: 'Noise-cancelling over-ear headphones.',
          price: 150.0,
          category: 'Electronics',
        ),
        Gift(
          id: 'gift2',
          name: 'Smart Watch',
          imageBase64: null,
          description: 'Fitness tracking and notifications.',
          price: 200.0,
          category: 'Electronics',
        ),
      ],
    ),
    Wishlist(
      id: 'wishlist2',
      name: 'Christmas Wishlist',
      gifts: [
        Gift(
          id: 'gift3',
          name: 'Coffee Maker',
          imageBase64: null,
          description: 'Brews coffee quickly and easily.',
          price: 80.0,
          category: 'Electronics',
        ),
        Gift(
          id: 'gift4',
          name: 'Bookshelf',
          imageBase64: null,
          description: '5-tier wooden bookshelf.',
          price: 120.0,
          category: 'Electronics',
        ),
      ],
    ),
    Wishlist(
      id: 'wishlist3',
      name: 'Travel Wishlist',
      gifts: [
        Gift(
          id: 'gift5',
          name: 'Backpack',
          imageBase64: null,
          description: 'Durable hiking backpack.',
          price: 100.0,
          category: 'Electronics',
        ),
        Gift(
          id: 'gift6',
          name: 'Travel Pillow',
          imageBase64: null,
          description: 'Memory foam pillow for comfortable travel.',
          price: 30.0,
          category: 'Electronics',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final wishlist = wishlists[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditWishlistScreen(wishlist: wishlist),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Wishlist Header (Full-width colored section)
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _getRandomColor(),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                          ),
                          // Wishlist Content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wishlist.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${wishlist.gifts.length} Items',
                                      style:
                                          const TextStyle(color: Colors.grey),
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
                childCount: wishlists.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the create wishlist screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNewWishlistScreen(),
            ),
          );
        },
        tooltip: 'Add New Wishlist',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to generate a random color
  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
