import 'package:fitness_app/admin/usermanage.dart'; // Assuming this path is still relevant or will be adapted
import 'package:flutter/material.dart';

// Placeholder screens - You'll create these below
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(child: Text('Attendance Screen - Implement User List and Firebase')),
    );
  }
}

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout"),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(child: Text('Workout Screen')),
    );
  }
}

class DietNutritionScreen extends StatelessWidget {
  const DietNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet & Nutrition"),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(child: Text('Diet & Nutrition Screen')),
    );
  }
}

class TrainerUsersScreen extends StatelessWidget {
  const TrainerUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(child: Text('Trainer Users Screen - Implement User List and Firebase')),
    );
  }
}


class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainer Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange, // Changed to orange for Trainer theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _buildCard(context, "Attendance", Icons.event_available,
                const AttendanceScreen()), // Placeholder AttendanceScreen
            _buildCard(context, "Workout", Icons.fitness_center,
                const WorkoutScreen()), // Placeholder WorkoutScreen
            _buildCard(context, "Diet & Nutrition", Icons.restaurant_menu,
                const DietNutritionScreen()), // Placeholder DietNutritionScreen
            _buildCard(context, "Users", Icons.group,
                const TrainerUsersScreen()), // Placeholder TrainerUsersScreen
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget route) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => route,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: Colors.deepOrange), // Trainer theme color
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}