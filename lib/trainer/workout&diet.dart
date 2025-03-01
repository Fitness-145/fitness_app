import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: StreamBuilder(
        stream: _users.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No users found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0), // Add padding around the list
            children: snapshot.data!.docs.map((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final name = userData['name'] ?? '';
              final age = userData['age'] ?? '';
              final height = userData['height'] ?? '';
              final weight = userData['weight'] ?? '';

              return Card( // Use Card for a box-like appearance
                elevation: 2, // Add elevation for a subtle shadow
                margin: const EdgeInsets.symmetric(vertical: 8), // Add margin between cards
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Add padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8), // Add spacing between text elements
                      Text('Age: $age'),
                      Text('Height: $height cm'),
                      Text('Weight: $weight kg'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}