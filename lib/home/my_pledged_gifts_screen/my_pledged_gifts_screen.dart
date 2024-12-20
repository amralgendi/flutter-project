import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/data/wishlists/models/gift.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';

class MyPledgedGiftsScreen extends StatefulWidget {
  const MyPledgedGiftsScreen({super.key});

  @override
  State<MyPledgedGiftsScreen> createState() => _MyPledgedGiftsScreenState();
}

class _MyPledgedGiftsScreenState extends State<MyPledgedGiftsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("gifts")
            .where("pledgedBy",
                isEqualTo: UserSessionManager.instance.getCurrentUser()!.uid)
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
              child: Text('No events found.'),
            );
          }

          List<Gift> pledgedGifts =
              snapshot.data!.docs.map((doc) => Gift.FromDocument(doc)).toList();

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return Dismissible(
                key: Key(gift.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${gift.name} has been deleted'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 16),
                  alignment: Alignment.centerRight,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gift Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gift.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gift.price.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   "For: ${gift["friendName"]}",
                            //   style: const TextStyle(
                            //     fontSize: 14,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            // const SizedBox(height: 4),
                            // Text(
                            //   "Due Date: ${gift["dueDate"]}",
                            //   style: const TextStyle(
                            //     fontSize: 14,
                            //     color: Colors.orange,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                          ],
                        ),
                        // Icon for styling or action (optional)
                        const Icon(
                          Icons.card_giftcard,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
