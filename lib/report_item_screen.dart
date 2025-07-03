import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportItemScreen extends StatefulWidget {
  @override
  _ReportItemScreenState createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _itemController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController(); // Controller for the date

  final _dbRef = FirebaseDatabase.instance.ref().child("users");

  void _submitItemReport() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // User is not logged in, show error
      return;
    }

    String item = _itemController.text;
    String category = _categoryController.text;
    String description = _descriptionController.text;
    String location = _locationController.text;
    String phone = _phoneController.text;
    String date = _dateController.text; // Get the selected date

    final itemData = {
      'item_name': item,
      'category': category,
      'description': description,
      'location': location,
      'phone': phone,
      'status': 'Missing',
      'timestamp': DateTime.now().toString(),
      'date_lost': date, // Save the lost date
    };

    // Push item data with a unique ID and save it under the user's UID
    final newItemRef = _dbRef.child(currentUser.uid).child("reported_items").push();
    final itemId = newItemRef.key;

    // Save the item data along with the item_id
    newItemRef.set({
      'item_id': itemId,
      ...itemData,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item Reported Successfully')));
      _itemController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _phoneController.clear();
      _dateController.clear();  // Clear date field
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Report Item')));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format the date to YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Lost/Found Item')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _itemController, decoration: InputDecoration(labelText: 'Item Name')),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'Category')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location')),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {});
              },
            ),
            // Button to select date
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date Item Lost'),
              readOnly: true,  // Prevent typing in the date field
              onTap: () => _selectDate(context), // Trigger date picker when tapped
            ),
            ElevatedButton(onPressed: _submitItemReport, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
