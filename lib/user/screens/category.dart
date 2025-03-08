import 'package:fitness_app/user/screens/myplan.dart';
import 'package:fitness_app/user/screens/profilescreen.dart';
import 'package:fitness_app/user/screens/sub_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class CustomizeInterestsScreen extends StatefulWidget {
  const CustomizeInterestsScreen({super.key});

  @override
  _CustomizeInterestsScreenState createState() =>
      _CustomizeInterestsScreenState();
}

class _CustomizeInterestsScreenState extends State<CustomizeInterestsScreen> {
  int _currentIndex = 0; // Track the selected bottom navigation item
  bool isPaymentSuccessful = false; // Variable to hold payment status
  int _selectedInterestCount = 0; // Track the number of selected interests

  // Track selected interests
  final List<Map<String, dynamic>> interests = [
    {'interest': 'Gym', 'icon': Icons.fitness_center, 'selected': false},
    {'interest': 'Karate', 'icon': Icons.sports_kabaddi, 'selected': false},
    {'interest': 'Martial Arts', 'icon': Icons.sports_martial_arts, 'selected': false}, // Updated icon
    {'interest': 'Badminton', 'icon': Icons.sports_tennis, 'selected': false},
    {'interest': 'Shooting', 'icon': Icons.sports_esports, 'selected': false},
    {'interest': 'Boxing', 'icon': Icons.sports_mma, 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus(); // Call method to check payment status on screen load
  }

  _checkPaymentStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool paymentStatus = prefs.getBool('isPaymentSuccessful') ?? false; // Default to false if not found
    setState(() {
      isPaymentSuccessful = paymentStatus;
    });
    if (isPaymentSuccessful) {
      print("Payment was successful in CustomizeInterestsScreen!");
      // Navigate to MyPlanScreen if payment is successful
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  MyPlanScreen()),
        );
      });
    } else {
      print("Payment was not successful or not yet made in CustomizeInterestsScreen.");
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Navigate to My Plan Screen when "My Plan" is tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  MyPlanScreen(),
        ),
      );
    } else if (index == 2) {
      // Navigate to the ProfileScreen when the Profile icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print the payment status in the build method as well for every build cycle
    print("Payment Successful Status in Build Method: $isPaymentSuccessful");

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
      body: isPaymentSuccessful
          ?  MyPlanScreen() // Show MyPlanScreen if payment is successful
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Time to customize your interests',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  if (isSelected) {
                                    // Deselect the interest
                                    interest['selected'] = false;
                                    _selectedInterestCount--;
                                  } else {
                                    // Check if the user can select another interest
                                    if (_selectedInterestCount < 2) {
                                      interest['selected'] = true;
                                      _selectedInterestCount++;
                                    } else {
                                      // Show a SnackBar if the user tries to select more than 2 interests
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('You can select a maximum of 2 interests.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: isSelected
                                      ? Colors.purple[200]
                                      : Colors.purple[50],
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.purple[200]!,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      interest['icon'],
                                      color: isSelected ? Colors.white : Colors.deepPurple,
                                      size: 35,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(interest['interest'],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.deepPurple),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          List<String> selectedInterests = interests
                              .where((interest) => interest['selected'])
                              .map((interest) => interest['interest'] as String)
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
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Continue',
                            style: TextStyle(color: Colors.purple)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}