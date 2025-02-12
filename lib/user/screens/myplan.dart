import 'package:flutter/material.dart';

class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Plan"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Workout Plan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPlanCard("Full Body Workout", "5 Days a Week"),
            _buildPlanCard("Strength Training", "3 Days a Week"),
            const SizedBox(height: 20),
            
            const Text(
              "Diet Plan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPlanCard("High Protein Diet", "2000 Calories/Day"),
            _buildPlanCard("Keto Diet", "Low Carb, High Fat"),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
        onTap: () {
          // Future: Navigate to detailed plan page
        },
      ),
    );
  }
}
