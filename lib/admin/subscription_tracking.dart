import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubscriptionTracking extends StatefulWidget {
  const SubscriptionTracking({super.key});

  @override
  _SubscriptionTrackingState createState() => _SubscriptionTrackingState();
}

class _SubscriptionTrackingState extends State<SubscriptionTracking> {
  String searchQuery = ""; // Search query for users
  Set<String> selectedUsers = {}; // Set to track selected users
  String sortBy = 'name'; // Default sorting by name

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _openUserDetails(BuildContext context, Map<String, dynamic>? userData) {
    if (userData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage(userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Users Subscription Status",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: selectedUsers.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteSelectedUsers(),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: sortBy,
                    onChanged: (String? newValue) {
                      setState(() {
                        sortBy = newValue!;
                      });
                    },
                    items: <String>['name', 'subscription']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
              ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search User",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("users").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> users = snapshot.data!.docs;

                if (searchQuery.isNotEmpty) {
                  users = users
                      .where((user) => user['name']
                          .toLowerCase()
                          .contains(searchQuery))
                      .toList();
                }

                if (sortBy == 'name') {
                  users.sort((a, b) =>
                      a['name'].toString().compareTo(b['name'].toString()));
                } else if (sortBy == 'subscription') {
                  users.sort((a, b) {
                    bool aSubscribed = a['issubscribed'] ?? false;
                    bool bSubscribed = b['issubscribed'] ?? false;
                    return aSubscribed == bSubscribed
                        ? 0
                        : (aSubscribed ? -1 : 1);
                  });
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    bool isSelected = selectedUsers.contains(user.id);
                    final userData = user.data() as Map<String, dynamic>?;

                    return GestureDetector(
                      onTap: () => _openUserDetails(context, userData),
                      onLongPress: () {
                        setState(() {
                          if (isSelected) {
                            selectedUsers.remove(user.id);
                          } else {
                            selectedUsers.add(user.id);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey[300] : Colors.white,
                          border:
                              Border.all(color: Colors.deepPurple, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            user['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user['issubscribed'] == true
                                ? "Subscribed"
                                : "Not Subscribed",
                            style: TextStyle(
                              color: user['issubscribed'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedUsers() async {
    for (String userId in selectedUsers) {
      await _firestore.collection("users").doc(userId).delete();
    }
    setState(() {
      selectedUsers.clear();
    });
  }
}

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const UserDetailsPage({required this.userData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${userData['name']} - Subscription Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription: ${userData['issubscribed'] ? "Active" : "Inactive"}', style: const TextStyle(fontSize: 18)),
            Text('Package: ${userData['package'] ?? "N/A"}', style: const TextStyle(fontSize: 18)),
            Text('Batch: ${userData['batch'] ?? "N/A"}', style: const TextStyle(fontSize: 18)),
            Text('Total Amount: \$${userData['total_amount'] ?? "N/A"}', style: const TextStyle(fontSize: 18)),
            Text('Amount Paid: \$${userData['amount_paid'] ?? "N/A"}', style: const TextStyle(fontSize: 18)),
            Text('Pending Amount: \$${userData['pending_amount'] ?? "N/A"}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}