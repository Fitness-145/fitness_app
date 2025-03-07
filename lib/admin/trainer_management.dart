import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerManagement extends StatefulWidget {
  const TrainerManagement({super.key});
  @override
  _TrainerManagementState createState() => _TrainerManagementState();
}

class _TrainerManagementState extends State<TrainerManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController(); // For password change

  String? _currentTrainerId; // To track the trainer being edited

  void _saveTrainerDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_currentTrainerId == null) {
          // Create a new trainer
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          await FirebaseFirestore.instance.collection('trainers').add({
            'name': _nameController.text,
            'specialization': _specializationController.text,
            'experience': _experienceController.text,
            'contact': _contactController.text,
            'email': _emailController.text,
            'uid': userCredential.user!.uid,
          });
        } else {
          // Update existing trainer
          await FirebaseFirestore.instance.collection('trainers').doc(_currentTrainerId).update({
            'name': _nameController.text,
            'specialization': _specializationController.text,
            'experience': _experienceController.text,
            'contact': _contactController.text,
            'email': _emailController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trainer details saved successfully!')),
        );

        _clearForm();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  void _deleteTrainer(String trainerId) async {
    await FirebaseFirestore.instance.collection('trainers').doc(trainerId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trainer deleted successfully!')),
    );
  }

  void _editTrainer(String trainerId, Map<String, dynamic> data) {
    setState(() {
      _currentTrainerId = trainerId;
      _nameController.text = data['name'];
      _specializationController.text = data['specialization'];
      _experienceController.text = data['experience'];
      _contactController.text = data['contact'];
      _emailController.text = data['email'];
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Trainer'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Trainer Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(labelText: 'Specialization'),
                validator: (value) => value!.isEmpty ? 'Enter specialization' : null,
              ),
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: 'Experience (years)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter experience' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Enter contact' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email ID'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password (optional)'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                 _saveTrainerDetails();
                if (_newPasswordController.text.isNotEmpty) {
                  await _changePassword(data['uid']);
                }
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String uid) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  void _clearForm() {
    _currentTrainerId = null;
    _nameController.clear();
    _specializationController.clear();
    _experienceController.clear();
    _contactController.clear();
    _emailController.clear();
    _passwordController.clear();
    _newPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trainer Management')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('trainers').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Trainers Available'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.purple),
                      ),
                      child: ListTile(
                        title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Specialization: ${data['specialization']}'),
                            Text('Email: ${data.containsKey('email') ? data['email'] : 'N/A'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTrainer(doc.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTrainer(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _clearForm();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Add Trainer'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Trainer Name'),
                          validator: (value) => value!.isEmpty ? 'Enter name' : null,
                        ),
                        TextFormField(
                          controller: _specializationController,
                          decoration: InputDecoration(labelText: 'Specialization'),
                          validator: (value) => value!.isEmpty ? 'Enter specialization' : null,
                        ),
                        TextFormField(
                          controller: _experienceController,
                          decoration: InputDecoration(labelText: 'Experience (years)'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? 'Enter experience' : null,
                        ),
                        TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(labelText: 'Contact'),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.isEmpty ? 'Enter contact' : null,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email ID'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty ? 'Enter email' : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Enter password' : null,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        _saveTrainerDetails();
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Add Trainer'),
          ),
        ],
      ),
    );
  }
}