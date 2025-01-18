import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To pick images from gallery/camera

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  // Default user details
  String userName = 'John Doe';
  String userEmail = 'johndoe@example.com';
  int userAge = 25;
  String fitnessGoal = 'Lose Weight'; // Default goal
  double height = 175; // Default height in cm
  double weight = 70; // Default weight in kg
  String gender = 'Male'; // Default gender

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the default values
    nameController.text = userName;
    emailController.text = userEmail;
    ageController.text = userAge.toString();
    heightController.text = height.toString();
    weightController.text = weight.toString();
    goalController.text = fitnessGoal;
  }

  // Function to handle profile pic change (using Image Picker)
  Future<void> changeProfilePic() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Set new profile picture path
        // profilePic = pickedFile.path; 
      });
    }
  }

  // Function to handle editing any field
  void editField(String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: field == 'Name'
              ? TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Name',
                  ),
                )
              : field == 'Email'
                  ? TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Email',
                      ),
                    )
                  : field == 'Age'
                      ? TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter Age',
                          ),
                        )
                      : field == 'Height'
                          ? TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Enter Height (cm)',
                              ),
                            )
                          : field == 'Weight'
                              ? TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Weight (kg)',
                                  ),
                                )
                              : TextField(
                                  controller: goalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Fitness Goal',
                                  ),
                                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (field == 'Name') {
                    userName = nameController.text;
                  } else if (field == 'Email') {
                    userEmail = emailController.text;
                  } else if (field == 'Age') {
                    userAge = int.parse(ageController.text);
                  } else if (field == 'Height') {
                    height = double.parse(heightController.text);
                  } else if (field == 'Weight') {
                    weight = double.parse(weightController.text);
                  } else if (field == 'Goal') {
                    fitnessGoal = goalController.text;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture Section with Icon
            GestureDetector(
              onTap: changeProfilePic,  // Change profile pic when tapped
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change your profile picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // User Information Section
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Editable Name Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(userName),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Name'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Editable Email Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(userEmail),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Email'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Editable Age Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(userAge.toString()),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Age'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Editable Height Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(height.toString() + ' cm'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Height'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Editable Weight Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(weight.toString() + ' kg'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Weight'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Editable Goal Field with Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(fitnessGoal),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purple),
                  onPressed: () => editField('Goal'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Continue button functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
