import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_screen.dart';  // Import your UserProfileScreen

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logout function
  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String displayName = user?.displayName ?? 'Guest';  // Use displayName if available

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,  // AppBar color matches the login button color
        title: Text(
          'Welcome $displayName',  // Display username instead of email
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        // Use ConstrainedBox or set max width for responsiveness
        constraints: BoxConstraints(maxWidth: 600),  // Set max width for responsiveness
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],  // Same blue gradient as the login screen
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to the Lost & Found Tracker',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              SizedBox(height: 30),  // Spacing between text and buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,  // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
                ),
                onPressed: () => Navigator.pushNamed(context, '/report'),
                child: Text('Report Lost/Found Item'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,  // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
                ),
                onPressed: () => Navigator.pushNamed(context, '/search'),
                child: Text('Search for Lost/Found Items'),
              ),
              SizedBox(height: 20),  // Spacing between buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,  // Button background color matches login color
                  foregroundColor: Colors.white,  // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()), // Navigate to profile screen
                ),
                child: Text('Go to Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
