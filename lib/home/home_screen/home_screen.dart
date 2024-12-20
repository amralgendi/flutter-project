import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/home/add_friend_screen/add_friend_screen.dart';
import 'package:hedieaty/home/create_event_screen/create_event_screen.dart';
import 'package:hedieaty/home/data/users/models/user.dart';
import 'package:hedieaty/onboarding/managers/user_session_manager.dart';
import '../create_wishlist_screen/create_wishlist_screen.dart';
import '../friend_details/friend_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  List<User> followedUsers = [];

  // Mock search results
  List<Map<String, String>> searchResults = [
    {"gift": "Smart Watch", "friend": "Alice"},
    {"gift": "Wireless Earbuds", "friend": "Bob"},
    {"gift": "Coffee Maker", "friend": "Charlie"},
  ];

  // Filtered list based on search query
  List<Map<String, String>> filteredResults = [];

  _loadFollowers() async {
    String? userId = UserSessionManager.instance.getCurrentUser()?.uid;

    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!doc.exists) return;

    final user = User.fromDocument(doc);

    if (user.followers.isEmpty) return;

    final followedUserDocs = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: user.followers)
        .get();

    setState(() {
      followedUsers =
          followedUserDocs.docs.map((d) => User.fromDocument(d)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredResults = searchResults; // Initially show all results

    _loadFollowers();
  }

  // Update the filtered list when searching
  void _updateSearchResults(String query) {
    setState(() {
      filteredResults = searchResults
          .where((result) =>
              result["gift"]!.toLowerCase().contains(query.toLowerCase()) ||
              result["friend"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _updateSearchResults,
                // style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search friend gifts...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : const Text('Home'),
        // actions: [
        //   IconButton(
        //     icon: Icon(_isSearching ? Icons.close : Icons.search),
        //     onPressed: () {
        //       setState(() {
        //         if (_isSearching) {
        //           _searchController.clear();
        //           filteredResults = searchResults; // Reset the search
        //         }
        //         _isSearching = !_isSearching;
        //       });
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Results Section
            if (_isSearching)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    return ListTile(
                      leading: const Icon(Icons.card_giftcard),
                      title: Text(result["gift"]!),
                      subtitle: Text('For: ${result["friend"]}'),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Create prominent buttons
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBigButton(
                              context,
                              icon: Icons.event,
                              label: 'Add Event',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateEventScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildBigButton(
                              context,
                              icon: Icons.add_shopping_cart,
                              label: 'Add Wishlist',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateNewWishlistScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // List of Friends/Items
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          User user = followedUsers[index];

                          return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("events")
                                .where("userId", isEqualTo: user.id)
                                .where("date",
                                    isGreaterThan: DateTime.now().toLocal())
                                .snapshots(),
                            builder: (context, snapshot) {
                              String eventResult = snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? "..."
                                  : snapshot.hasError ||
                                          !snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty
                                      ? "No"
                                      : "Yes";
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: const CircleAvatar(
                                    radius: 30,
                                    child:
                                        Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Upcoming event: $eventResult',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FriendDetailsScreen(
                                                user: user,
                                              )),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        childCount: followedUsers.length,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFriendsScreen(),
            ),
          );
        },
        label: const Text('Add Friend'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBigButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
