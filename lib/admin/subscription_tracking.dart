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
  int currentPage = 1;
  final int itemsPerPage = 5; // Same as AttendancePage

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> getPaginatedUsers(List<QueryDocumentSnapshot> users) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, users.length);
    return users.sublist(startIndex, endIndex);
  }

  void _nextPage(int totalUsers) {
    if (currentPage * itemsPerPage < totalUsers) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
    }
  }

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
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Users Subscription Status",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (selectedUsers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _deleteSelectedUsers(),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: sortBy,
                onChanged: (String? newValue) {
                  setState(() {
                    sortBy = newValue!;
                    currentPage = 1; // Reset to first page on sort change
                  });
                },
                items: <String>['name', 'subscription']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                borderRadius: BorderRadius.circular(8),
                underline: Container(
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search User",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  currentPage = 1; // Reset to first page on search
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
                      .where((user) =>
                          user['name'].toLowerCase().contains(searchQuery))
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

                final paginatedUsers = getPaginatedUsers(users);

                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: screenWidth - 8, // Match screen width minus margins
                              ),
                              child: DataTable(
                                columnSpacing: 16,
                                headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.deepPurple.shade100),
                                columns: const [
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Subscription',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: paginatedUsers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final user = entry.value;
                                  final isSelected =
                                      selectedUsers.contains(user.id);
                                  final userData = user.data() as Map<String, dynamic>?;

                                  return DataRow(
                                    color: MaterialStateColor.resolveWith((states) =>
                                        index % 2 == 0
                                            ? Colors.grey.shade100
                                            : Colors.white),
                                    selected: isSelected,
                                    onSelectChanged: (selected) {
                                      setState(() {
                                        if (selected!) {
                                          selectedUsers.add(user.id);
                                        } else {
                                          selectedUsers.remove(user.id);
                                        }
                                      });
                                    },
                                    cells: [
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 2 - 16, // Half width minus spacing
                                          ),
                                          child: Text(
                                            user['name'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: () => _openUserDetails(context, userData),
                                      ),
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 2 - 16, // Half width minus spacing
                                          ),
                                          child: Text(
                                            user['issubscribed'] == true
                                                ? "Subscribed"
                                                : "Not Subscribed",
                                            style: TextStyle(
                                              color: user['issubscribed'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_left),
                          ),
                          Text('$currentPage',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => _nextPage(users.length),
                            icon: const Icon(Icons.arrow_right),
                          ),
                        ],
                      ),
                    ),
                  ],
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
      appBar: AppBar(
        title: Text('${userData['name']} - Subscription Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package: ${userData['package'] ?? "N/A"}',
                style: const TextStyle(fontSize: 18)),
            Text('Batch: ${userData['batch'] ?? "N/A"}',
                style: const TextStyle(fontSize: 18)),
            Text('Total Amount: \$${userData['total_amount'] ?? "N/A"}',
                style: const TextStyle(fontSize: 18)),
            Text('Amount Paid: \$${userData['amount_paid'] ?? "N/A"}',
                style: const TextStyle(fontSize: 18)),
            Text('Pending Amount: \$${userData['pending_amount'] ?? "N/A"}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}