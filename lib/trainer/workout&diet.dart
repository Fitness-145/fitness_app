import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  void _editUser(String userId, Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['name']);
    TextEditingController ageController = TextEditingController(text: userData['age'].toString());
    TextEditingController heightController = TextEditingController(text: userData['height'].toString());
    TextEditingController weightController = TextEditingController(text: userData['weight'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
            TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
            TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _users.doc(userId).update({
                'name': nameController.text,
                'age': int.tryParse(ageController.text) ?? 0,
                'height': int.tryParse(heightController.text) ?? 0,
                'weight': int.tryParse(weightController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _viewUser(Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userData: userData),
      ),
    );
  }

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
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final userId = doc.id;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['name'] ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Age: ${userData['age']}'),
                      Text('Height: ${userData['height']} cm'),
                      Text('Weight: ${userData['weight']} kg'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _viewUser(userData),
                            child: const Text('View'),
                          ),
                          TextButton(
                            onPressed: () => _editUser(userId, userData),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
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

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userData['name'] ?? 'User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Age: ${userData['age']}'),
            Text('Height: ${userData['height']} cm'),
            Text('Weight: ${userData['weight']} kg'),
          ],
        ),
      ),
    );
  }
}
