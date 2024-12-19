import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/events/models/event.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the event's data
    _nameController = TextEditingController(text: widget.event.name);
    _dateController = TextEditingController(text: widget.event.date);
    _categoryController = TextEditingController(text: widget.event.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Event Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Create a new event object with the updated details
                Event updatedEvent = Event(
                  id: widget.event.id,
                  name: _nameController.text,
                  date: _dateController.text,
                  category: _categoryController.text,
                  userId: widget.event.userId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated')),
                );
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
