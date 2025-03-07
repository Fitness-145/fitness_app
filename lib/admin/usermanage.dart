import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String selectedRole = "User"; // Default role filter
  String selectedSort = "Date";
  String searchQuery = "";
  Set<String> selectedUsers = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Management",
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
            : [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDetails(context, null, null),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDropdown(
                title: "Filter by Role",
                value: selectedRole,
                items: ["All Users", "User", "Trainer"],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              _buildDropdown(
                title: "Sort By",
                value: selectedSort,
                items: ["Date", "Subscription", "Name"],
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("users").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> users = snapshot.data!.docs;

                // Apply role filter
                if (selectedRole != "All Users") {
                  users = users
                      .where(
                          (user) => user['role'] == selectedRole.toLowerCase())
                      .toList();
                }

                // Apply search filter
                if (searchQuery.isNotEmpty) {
                  users = users
                      .where((user) =>
                          user['name'].toLowerCase().contains(searchQuery))
                      .toList();
                }

                // Apply sorting
                if (selectedSort == "Name") {
                  users.sort((a, b) => a['name'].compareTo(b['name']));
                } else if (selectedSort == "Date") {
                  users.sort(
                      (a, b) => b['created_at'].compareTo(a['created_at']));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    bool isSelected = selectedUsers.contains(user.id);

                    return StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('attendance')
                          .where('userId', isEqualTo: user.id)
                          .snapshots(),
                      builder: (context, attendanceSnapshot) {
                        if (!attendanceSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        int attendanceCount = attendanceSnapshot.data!.docs.length;

                        return GestureDetector(
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
                              border: Border.all(
                                  color: Colors.deepPurple, width: 1.5),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Email: ${user['email']} | Role: ${user['role']}"),
                                  Text("Attendance Count: $attendanceCount"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _showUserDetails(
                                        context, user, user.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteUser(user.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildDropdown(
      {required String title,
      required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  void _showUserDetails(
      BuildContext context, QueryDocumentSnapshot? user, String? userId) {
    final formKey = GlobalKey<FormState>();

    TextEditingController nameController =
        TextEditingController(text: user?['name'] ?? '');
    TextEditingController emailController =
        TextEditingController(text: user?['email'] ?? '');
    TextEditingController phoneController =
        TextEditingController(text: user?['phone'] ?? '');
    TextEditingController ageController =
        TextEditingController(text: user?['age']?.toString() ?? '');
    TextEditingController heightController =
        TextEditingController(text: user?['height']?.toString() ?? '');
    TextEditingController passwordController = TextEditingController();

    String role = user?['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? "Add New User" : "Edit User"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Name",
                    (value) => value!.isEmpty ? "Enter a valid name" : null),
                _buildTextField(
                    emailController,
                    "Email",
                    (value) =>
                        value!.contains("@") ? null : "Enter a valid email"),
                _buildTextField(
                    phoneController,
                    "Phone",
                    (value) => value!.length == 10
                        ? null
                        : "Enter a valid phone number"),
                _buildTextField(ageController, "Age", (value) {
                  int? age = int.tryParse(value!);
                  return (age != null && age >= 10 && age <= 99)
                      ? null
                      : "Age must be 10-99";
                }),
                _buildTextField(
                    heightController,
                    "Height",
                    (value) => int.tryParse(value!) != null
                        ? null
                        : "Enter a valid height"),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                      labelText: 'Role', border: OutlineInputBorder()),
                  items: ['user', 'trainer'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      role = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a role' : null,
                ),
                if (user == null)
                  _buildTextField(
                      passwordController,
                      "Password",
                      (value) =>
                          value!.isEmpty ? "Password is required" : null),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Map<String, dynamic> userData = {
                    "name": nameController.text,
                    "email": emailController.text,
                    "phone": phoneController.text,
                    "age": int.parse(ageController.text),
                    "height": int.parse(heightController.text),
                    "role": role.toLowerCase(),
                    "created_at": Timestamp.now(),
                  };
                  if (user == null) {
                    userData['password'] = passwordController.text;
                  }

                  _firestore
                      .collection("users")
                      .doc(userId ?? _firestore.collection("users").doc().id)
                      .set(userData);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.deepPurple),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        validator: validator,
      ),
    );
  }

  void _deleteUser(String userId) {
    _firestore.collection("users").doc(userId).delete();
  }

  void _deleteSelectedUsers() {
    for (String userId in selectedUsers) {
      _firestore.collection("users").doc(userId).delete();
    }
    setState(() {
      selectedUsers.clear();
    });
  }
}