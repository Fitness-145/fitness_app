import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  _TrainerDashboardState createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String trainerId;

  @override
  void initState() {
    super.initState();
    trainerId = _auth.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle('Trainees'),
            _buildTraineeList(),
            _buildSectionTitle('Workout & Diet Plans'),
            _buildWorkoutAndDietPlans(),
            _buildSectionTitle('Appointments'),
            _buildSchedule(),
            _buildSectionTitle('Messages'),
            _buildMessagingFeature(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
    );
  }

  Widget _buildTraineeList() {
    return StreamBuilder(
      stream: _firestore.collection('users').where('trainerId', isEqualTo: trainerId).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var trainees = snapshot.data!.docs;
        return Column(
          children: trainees.map((trainee) => ListTile(
                title: Text(trainee['name']),
                subtitle: Text(trainee['email']),
              )).toList(),
        );
      },
    );
  }

  Widget _buildWorkoutAndDietPlans() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to workout plan management page
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
      child: const Text('Manage Plans', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSchedule() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to schedule management
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
      child: const Text('Manage Schedule', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildMessagingFeature() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to chat feature
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
      child: const Text('Open Chat', style: TextStyle(color: Colors.white)),
    );
  }
}
