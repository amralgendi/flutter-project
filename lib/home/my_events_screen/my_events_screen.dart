import 'package:flutter/material.dart';
import 'package:hedieaty/home/edit_event_screen/edit_event_screen.dart';
import '../create_event_screen/create_event_screen.dart';
import '../data/events/models/event.dart';

class MyEventsScreen extends StatelessWidget {
  MyEventsScreen({super.key});

  List<Event> events = [
    Event(
      id: '1',
      name: 'Tech Conference 2024',
      date: '2024-12-25', // Future date
      category: 'Technology',
      userId: 'user123',
    ),
    Event(
      id: '2',
      name: 'Music Festival',
      date: '2024-12-19', // Today's date
      category: 'Entertainment',
      userId: 'user456',
    ),
    Event(
      id: '3',
      name: 'Art Exhibition',
      date: '2024-12-15', // Past date
      category: 'Art',
      userId: 'user789',
    ),
    Event(
      id: '4',
      name: 'Corporate Meetup',
      date: '2025-01-10', // Future date
      category: 'Business',
      userId: 'user101',
    ),
    Event(
      id: '5',
      name: 'Charity Run',
      date: '2024-12-10', // Past date
      category: 'Sports',
      userId: 'user202',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sort by ${value}')),
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
          child: ListView(
        children: events
            .map((event) => Dismissible(
                  key: Key(
                      event.id), // You should have a unique ID for each event
                  direction:
                      DismissDirection.endToStart, // Swipe from right to left
                  onDismissed: (direction) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${event.name} deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 40),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEventScreen(event: event),
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
                        width: double
                            .infinity, // This will make the content fill the width
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Name
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Event Category and Date
                            Text(
                              '${event.category} - ${event.date}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            // Event Status with beautiful design
                            _buildStatusBadge(event.status),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      )),
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

  // Helper method to return a colored status badge for each status
  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Light background color for the badge
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

  // Helper function to return color for each status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Current':
        return Colors.green;
      case 'Past':
        return Colors.grey;
      default:
        return Colors.grey; // Default to grey if no match
    }
  }
}
