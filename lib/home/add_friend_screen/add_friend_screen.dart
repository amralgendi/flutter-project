import 'package:flutter/material.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  // Mock list of contacts
  List<Map<String, dynamic>> contacts = [
    {"name": "Evelyn Carter", "phone": "+1415123456", "isAdded": false},
    {"name": "Jack Wilson", "phone": "+4420765432", "isAdded": false},
    {"name": "Sophia Martinez", "phone": "+6178901234", "isAdded": false},
    {"name": "Liam Anderson", "phone": "+8198765432", "isAdded": false}
  ];

  // Controller for manual phone number input
  TextEditingController phoneNumberController = TextEditingController();

  // Add a contact manually
  void _addManualContact() {
    String phoneNumber = phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }
    setState(() {
      contacts.add({"name": "Manual Friend", "phone": phoneNumber, "isAdded": true});
      phoneNumberController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend added with phone number $phoneNumber')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Manual Add Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Add Friend Manually',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter phone number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addManualContact,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Friend"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Contacts List Section
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(contact['name']),
                    subtitle: Text(contact['phone']),
                    trailing: contact['isAdded']
                        ? const Text(
                      'Added',
                      style: TextStyle(color: Colors.green),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          contact['isAdded'] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${contact['name']} added as a friend!'),
                          ),
                        );
                      },
                      child: const Text('Add'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}