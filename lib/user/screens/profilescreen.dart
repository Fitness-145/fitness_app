import 'package:flutter/material.dart';



class ProfilePictureScreen extends StatelessWidget {
  const ProfilePictureScreen({super.key});

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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.person,
            color: Colors.purple,
            size: 80,
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
            'You can select a photo from one of these emojis or add your own photo as a profile picture',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                EmojiCircle(emoji: '🐵'),
                EmojiCircle(emoji: '👻'),
                EmojiCircle(emoji: '🐱'),
                EmojiCircle(emoji: '🐶'),
                EmojiCircle(emoji: '🦊'),
                // Add more emojis as desired
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Add custom photo upload functionality
            },
            child: const Text(
              'Add Custom Photo',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Spacer(),
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
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmojiCircle extends StatelessWidget {
  final String emoji;

  const EmojiCircle({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
