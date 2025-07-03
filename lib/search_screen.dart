import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  // Reference to Firebase Realtime Database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("users");

  // Search functionality to query Firebase
  void _searchItems() async {
    final query = _searchController.text.toLowerCase();

    // Query items from Firebase for all users
    final DatabaseEvent event = await _dbRef
        .orderByChild('reported_items') // Querying across all users' reported items
        .once();

    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> allItems = [];

      // Iterate over all users and their reported items
      usersMap.forEach((key, user) {
        final reportedItems = user['reported_items'];
        if (reportedItems != null) {
          reportedItems.forEach((itemKey, itemData) {
            final item = Map<String, dynamic>.from(itemData);
            // Search for the query match in each item
            if (item['item_name'].toLowerCase().contains(query)) {
              allItems.add(item);
            }
          });
        }
      });

      setState(() {
        _items = allItems;
      });
    } else {
      setState(() {
        _items = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Lost/Found Items'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar to input item name or category
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Item',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _items.clear();
                  });
                } else {
                  _searchItems(); // Update the results as the user types
                }
              },
            ),
            SizedBox(height: 10),
            // Display number of search results
            Text(
              'Found ${_items.length} item${_items.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // If no results found
            _items.isEmpty
                ? Center(child: Text('No items found. Try another search.'))
                : Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['item_name']),
                      subtitle: Text(item['location']),
                      trailing: Text(item['phone'] ?? 'No phone number'), // Show phone number if available
                      onTap: () {
                        // Show detailed item information in a dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(item['item_name']),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: ${item['category']}'),
                                Text('Description: ${item['description']}'),
                                Text('Location: ${item['location']}'),
                                Text('Phone: ${item['phone'] ?? 'No phone number'}'), // Include phone number
                                // Show the date the item was lost
                                Text('Date Lost: ${item['date_lost'] ?? 'No date provided'}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
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
