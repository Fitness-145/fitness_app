import 'package:fitness_app/admin/ContentManagement.dart';
import 'package:fitness_app/admin/adminmessages.dart';
import 'package:fitness_app/admin/attendence.dart';
import 'package:fitness_app/admin/subscription_tracking.dart';
import 'package:fitness_app/admin/trainer_management.dart';
import 'package:fitness_app/admin/usermanage.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Customize your AppBar color
        foregroundColor: Colors.white,     // Set the text/icon color on the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,    // Creates 2 columns in the grid
            crossAxisSpacing: 12, // Horizontal space between cards
            mainAxisSpacing: 12,  // Vertical space between cards
          ),
          children: [
            _buildCard(
              context,
              "User Management",
              Icons.person,
              const UserManagement(),
            ),
            _buildCard(
              context,
              "Content Management",
              Icons.library_books,
              const ContentManagement(),
            ),
            _buildCard(
              context,
              "Subscription Tracking",
              Icons.payment,
              const SubscriptionTracking(),
            ),
            _buildCard(
              context,
              "Messages",
              Icons.message,
              const AdminMessageScreen(),
            ),
            _buildCard(
              context,
              "Trainer Management",
              Icons.fitness_center,
              const TrainerManagement(),
            ),
            // Make sure 'AttendancePage' is defined in attendence.dart
            _buildCard(
              context,
              "Attendance",
              Icons.checklist, // or Icons.fact_check / Icons.check_box
              const AttendancePage(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a card that navigates to a new route on tap
  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget route) {
    return Card(
      elevation: 4, // Shadow depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Round the corners
      ),
      color: Colors.white, // Card background color
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // Match card corners for ripple
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.deepPurple, // Icon color
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center, // Center horizontally
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}