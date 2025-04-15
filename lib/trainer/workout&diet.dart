import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  void _viewUser(String userId, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userId: userId, userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.blueAccent,
      ),
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
              final String userId = doc.id;
              final String userName = userData['name'] ?? 'Unknown';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _viewUser(userId, userData),
                    child: const Text('View'),
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

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserDetailsScreen({super.key, required this.userId, required this.userData});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = FirebaseFirestore.instance.collection('plans').doc(widget.userId).get();
  }

  void _editPlanDetails(List<dynamic> currentPlan) {
    TextEditingController planController = TextEditingController();
    planController.text = currentPlan.join("\n");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Plan Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: planController,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter new plan details...",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  List<String> updatedPlan = planController.text.split("\n");
                  FirebaseFirestore.instance.collection('plans').doc(widget.userId).update({
                    'planDetails': updatedPlan,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan updated successfully!')),
                  );

                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _verifyPlan() async {
    await FirebaseFirestore.instance.collection('plans').doc(widget.userId).update({
      'verified': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan verified successfully!')),
    );

    setState(() {
      _planFuture = FirebaseFirestore.instance.collection('plans').doc(widget.userId).get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['name'] ?? 'User Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.userData['name'][0].toUpperCase(),
                      style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.userData['name'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _planFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading plan: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                      return const Text('No plan found for this user.');
                    }

                    final planData = snapshot.data!.data();
                    final List<dynamic> planDetails = planData?['planDetails'] ?? [];
                    final bool isVerified = planData?['verified'] ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plan Details:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: planDetails.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
                              title: Text(planDetails[index], style: const TextStyle(fontSize: 16)),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: isVerified ? null : _verifyPlan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isVerified ? Colors.green : Colors.blueAccent,
                            ),
                            child: Text(isVerified ? 'Verified' : 'Verify Plan'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _editPlanDetails(planDetails),
                            child: const Text('Edit Plan'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}