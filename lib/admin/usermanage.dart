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

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropdown(
                  title: "Filter by Role",
                  value: selectedRole,
                  items: ["All Users", "User", "Trainer"],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                      currentPage = 1; // Reset to first page on filter change
                    });
                  },
                ),
                _buildDropdown(
                  title: "Sort By",
                  value: selectedSort,
                  items: ["Date", "Name"],
                  onChanged: (value) {
                    setState(() {
                      selectedSort = value!;
                      currentPage = 1; // Reset to first page on sort change
                    });
                  },
                ),
              ],
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

                // Apply role filter
                if (selectedRole != "All Users") {
                  users = users
                      .where((user) =>
                          user['role'] == selectedRole.toLowerCase())
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
                  users.sort((a, b) =>
                      b['created_at'].compareTo(a['created_at']));
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
                                        'Email',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Role',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Attendance',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Actions',
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
                                            maxWidth: (screenWidth - 8) / 5 - 16, // Divide by 5 columns
                                          ),
                                          child: Text(
                                            user['name'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 5 - 16,
                                          ),
                                          child: Text(
                                            user['email'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 5 - 16,
                                          ),
                                          child: Text(
                                            user['role'].toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 5 - 16,
                                          ),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: _firestore
                                                .collection('attendance')
                                                .where('userId',
                                                    isEqualTo: user.id)
                                                .snapshots(),
                                            builder:
                                                (context, attendanceSnapshot) {
                                              if (!attendanceSnapshot.hasData) {
                                                return const CircularProgressIndicator(
                                                    strokeWidth: 2);
                                              }
                                              int attendanceCount =
                                                  attendanceSnapshot.data!.docs.length;
                                              return Text('$attendanceCount');
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (screenWidth - 8) / 5 - 16,
                                          ),
                                          child: Row(
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

  Widget _buildDropdown(
      {required String title,
      required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          borderRadius: BorderRadius.circular(8),
          underline: Container(
            height: 1,
            color: Colors.deepPurple,
          ),
        ),
      ],
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(user == null ? "Add New User" : "Edit User"),
              content: SingleChildScrollView(
                child: Form(
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
                          setDialogState(() {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
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
    setState(() {
      selectedUsers.remove(userId);
    });
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