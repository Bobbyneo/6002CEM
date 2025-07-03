import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _dbRef = FirebaseDatabase.instance.ref().child("users");
  late String _userId;
  List<Map<String, dynamic>> _reportedItems = [];

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _loadReportedItems();
  }

  // Load reported items from Firebase for the current user
  void _loadReportedItems() async {
    final event = await _dbRef.child(_userId).child("reported_items").once();
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      final Map<dynamic, dynamic> itemsMap = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _reportedItems = itemsMap.values.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();
      });
    }
  }

  // Delete the reported item from Firebase and update the UI
  void _deleteItem(String itemId) {
    if (itemId == null || itemId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item ID is missing')));
      return;
    }

    // Delete item from Firebase using itemId
    _dbRef.child(_userId).child("reported_items").child(itemId).remove().then((_) {
      // Update the UI to reflect the deletion
      setState(() {
        _reportedItems.removeWhere((item) => item['item_id'] == itemId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item Deleted Successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Delete Item')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Reported Items:'),
            Expanded(
              child: ListView.builder(
                itemCount: _reportedItems.length,
                itemBuilder: (context, index) {
                  final item = _reportedItems[index];
                  final itemId = item['item_id']; // Ensure each item has a unique ID

                  return Card(
                    child: ListTile(
                      title: Text(item['item_name']),
                      subtitle: Text('Status: ${item['status']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(itemId), // Pass the unique item ID
                      ),
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
                                Text('Date Lost: ${item['date_lost'] ?? 'No date provided'}'), // Display Date Lost
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
