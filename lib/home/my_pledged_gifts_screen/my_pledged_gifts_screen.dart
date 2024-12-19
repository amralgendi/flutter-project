import 'package:flutter/material.dart';

class MyPledgedGiftsScreen extends StatefulWidget {
  const MyPledgedGiftsScreen({super.key});

  @override
  State<MyPledgedGiftsScreen> createState() => _MyPledgedGiftsScreenState();
}

class _MyPledgedGiftsScreenState extends State<MyPledgedGiftsScreen> {
  // Example data for pledged gifts
  List<Map<String, dynamic>> pledgedGifts = [
    {
      "giftName": "Smart Watch",
      "price": "\$250",
      "friendName": "Alice",
      "dueDate": "2024-12-25",
    },
    {
      "giftName": "Wireless Earbuds",
      "price": "\$120",
      "friendName": "Bob",
      "dueDate": "2024-12-31",
    },
    {
      "giftName": "Coffee Maker",
      "price": "\$85",
      "friendName": "Charlie",
      "dueDate": "2025-01-10",
    },
  ];

  // Function to delete an item from the list
  void _deleteGift(int index) {
    setState(() {
      pledgedGifts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: pledgedGifts.isEmpty
          ? const Center(
        child: Text(
          'No pledged gifts yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Dismissible(
            key: Key(gift["giftName"]!),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteGift(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${gift["giftName"]} has been deleted'),
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
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
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
                          gift["giftName"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gift["price"],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "For: ${gift["friendName"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Due Date: ${gift["dueDate"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
      ),
    );
  }
}