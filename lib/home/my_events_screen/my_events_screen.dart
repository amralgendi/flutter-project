import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/home/edit_event_screen/edit_event_screen.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import '../create_event_screen/create_event_screen.dart';
import '../data/events/models/event.dart';

class MyEventsScreen extends StatelessWidget {
  MyEventsScreen({super.key});

  final String? userId = UserSessionManager.instance.getCurrentUser()?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sort by $value')),
              );
            },
            itemBuilder: (context) {
              return ['Name', 'Category', 'Status']
                  .map((option) => PopupMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                  .toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: userId) // Fetch events for the user
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

            // Map Firestore documents to Event objects
            List<Event> events = snapshot.data!.docs
                .map((doc) => Event.fromDocument(doc))
                .toList();

            return ListView(
              children: events
                  .map((event) => Dismissible(
                        key: Key(event.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          FirebaseFirestore.instance
                              .collection('events')
                              .doc(event.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${event.name} deleted')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditEventScreen(event: event),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.5),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${event.category} - ${event.date}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStatusBadge(event.status),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
        tooltip: 'Add New Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Current':
        return Colors.green;
      case 'Past':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
