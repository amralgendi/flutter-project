import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Event data
  String _eventName = '';
  String _eventDate = '';
  String _eventCategory = 'Social';

  // Function to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _eventDate = "${pickedDate.toLocal()}"
            .split(' ')[0]; // Format date as yyyy-mm-dd
      });
    }
  }

  // Function to save the event data
  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event successfully created!')),
        );

        Navigator.pop(context);
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                ),
                onChanged: (value) {
                  setState(() {
                    _eventName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Event Date Field (Date Picker)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  hintText: 'Select Event Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                controller: TextEditingController(text: _eventDate),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the event date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _eventCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _eventCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Event Category',
                ),
                items: <String>[
                  'Social',
                  'Business',
                  'Entertainment',
                  'Charity'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
