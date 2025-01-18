import 'package:fitness_app/user/screens/category_screen.dart';
import 'package:fitness_app/user/screens/profilescreen.dart';
import 'package:flutter/material.dart';

class CustomizeInterestsScreen extends StatefulWidget {
  const CustomizeInterestsScreen({super.key});

  @override
  _CustomizeInterestsScreenState createState() =>
      _CustomizeInterestsScreenState();
}

class _CustomizeInterestsScreenState extends State<CustomizeInterestsScreen> {
  int _currentIndex = 0; // Track the selected bottom navigation item

  // Track selected interests
  final List<Map<String, dynamic>> interests = [
    {'interest': 'Gym', 'icon': Icons.fitness_center, 'selected': false},
    {'interest': 'Karate', 'icon': Icons.sports_kabaddi, 'selected': false},
    {'interest': 'Martial Arts', 'icon': Icons.sports_mma, 'selected': false},
    {'interest': 'Badminton', 'icon': Icons.sports_tennis, 'selected': false},
    {'interest': 'Shooting', 'icon': Icons.sports_esports, 'selected': false},
    {'interest': 'Boxing', 'icon': Icons.sports_mma, 'selected': false},
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      // Navigate to the ProfilePictureScreen when the Profile icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePictureScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Time to customize your interests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Interest options
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .9,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  bool isSelected = interest['selected'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        interest['selected'] = !isSelected;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected ? Colors.purple[100] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.purple : Colors.grey,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            interest['icon'],
                            color: isSelected ? Colors.purple : Colors.grey,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(interest['interest'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Continue button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create a list of selected interests as a list of maps
                List<Map<String, dynamic>> selectedInterests = interests
                    .where((interest) => interest['selected'])
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(
                      selectedInterests: selectedInterests,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  const Text('Continue', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
