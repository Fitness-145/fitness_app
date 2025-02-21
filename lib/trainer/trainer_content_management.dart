import 'package:flutter/material.dart';

class TrainerContentManagement extends StatefulWidget {
  const TrainerContentManagement({super.key});

  @override
  State<TrainerContentManagement> createState() => _TrainerContentManagementState();
}

class _TrainerContentManagementState extends State<TrainerContentManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout & Diet Management"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Manage Workout and Diet Plans for your Trainees here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation to workout plans management
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Workout Management Feature coming soon!")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Manage Workout Plans"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation to diet plans management
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Diet Management Feature coming soon!")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Manage Diet Plans"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}