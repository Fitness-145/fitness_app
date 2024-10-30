import 'package:flutter/material.dart';



class ProfilePictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Icon(
            Icons.person,
            color: Colors.purple,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You can select a photo from one of these emojis or add your own photo as a profile picture',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                EmojiCircle(emoji: '🐵'),
                EmojiCircle(emoji: '👻'),
                EmojiCircle(emoji: '🐱'),
                EmojiCircle(emoji: '🐶'),
                EmojiCircle(emoji: '🦊'),
                // Add more emojis as desired
              ],
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Add custom photo upload functionality
            },
            child: Text(
              'Add Custom Photo',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Spacer(),
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
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
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

  const EmojiCircle({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Text(
          emoji,
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
