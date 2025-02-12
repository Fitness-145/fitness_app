import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness_app/user/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String profilePicUrl = "";
  String userName = "No Name";
  String userEmail = "No Email";
  int userAge = 0;
  String fitnessGoal = "No Goal";
  double height = 0.0;
  double weight = 0.0;
  String gender = "Not Specified";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user == null) {
      print("User not logged in.");
      setState(() => isLoading = false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(_user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          profilePicUrl = userData["profilePic"] ?? "";
          userName = userData["name"] ?? "No Name";
          userEmail = userData["email"] ?? "No Email";
          userAge = userData["age"] ?? 0;
          height = (userData["height"] ?? 0.0).toDouble();
          weight = (userData["weight"] ?? 0.0).toDouble();
          fitnessGoal = userData["fitnessGoal"] ?? "No Goal";
          gender = userData["gender"] ?? "Not Specified";
          isLoading = false;
        });
      } else {
        print("User document does not exist.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (_user == null) return;

    try {
      await _firestore.collection("users").doc(_user!.uid).update({
        "name": userName,
        "email": userEmail,
        "age": userAge,
        "height": height,
        "weight": weight,
        "fitnessGoal": fitnessGoal,
        "gender": gender,
        "profilePic": profilePicUrl,
      });

      print("User data updated successfully.");
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  Future<void> _changeProfilePic() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String fileName = "profile_${_user!.uid}.jpg";

    try {
      UploadTask uploadTask = FirebaseStorage.instance.ref().child("profile_pics/$fileName").putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() => profilePicUrl = downloadUrl);
      await _firestore.collection("users").doc(_user!.uid).update({"profilePic": profilePicUrl});

      print("Profile picture updated successfully.");
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  void _editField(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter $field"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                setState(() {
                  if (field == "Name") userName = controller.text;
                  if (field == "Email") userEmail = controller.text;
                  if (field == "Age") userAge = int.tryParse(controller.text) ?? userAge;
                  if (field == "Height") height = double.tryParse(controller.text) ?? height;
                  if (field == "Weight") weight = double.tryParse(controller.text) ?? weight;
                  if (field == "Goal") fitnessGoal = controller.text;
                });
                _updateUserData();
                Navigator.pop(context);
              },
              child: const Text("Save"),
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
        backgroundColor: Colors.purple,
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture Section
                  GestureDetector(
                    onTap: _changeProfilePic,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.purple,
                      backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                      child: profilePicUrl.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Profile Picture", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // User Information Section
                  _buildProfileField("Name", userName),
                  _buildProfileField("Email", userEmail),
                  _buildProfileField("Age", userAge.toString()),
                  _buildProfileField("Height", "$height cm"),
                  _buildProfileField("Weight", "$weight kg"),
                  _buildProfileField("Fitness Goal", fitnessGoal),
                  _buildProfileField("Gender", gender),

                  const SizedBox(height: 20),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false, // Clears navigation history
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.purple),
                onPressed: () {
                  TextEditingController controller = TextEditingController(text: value);
                  _editField(label, controller);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
