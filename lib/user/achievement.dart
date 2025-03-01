import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementGallery extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievement Gallery'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('achievements').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No achievements found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String imageUrl = snapshot.data!.docs[index]['imageUrl'];
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}