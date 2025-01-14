import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../App_thime.dart';

class AccommodationManagerPage extends StatefulWidget {
  final String userId;

  AccommodationManagerPage({required this.userId});

  @override
  _AccommodationManagerPageState createState() => _AccommodationManagerPageState();
}

class _AccommodationManagerPageState extends State<AccommodationManagerPage> {
  // Stream for fetching accommodations from Firestore
  final Stream<QuerySnapshot> _accommodationStream = FirebaseFirestore.instance.collection('accommodations').snapshots();

  // Method to fetch ratings for a specific accommodation
  Stream<QuerySnapshot> _ratingsStream(String accommodationId) {
    return FirebaseFirestore.instance
        .collection('Ratings')
        .where('accommodations_id', isEqualTo: accommodationId)
        .snapshots();
  }

  // Method to delete a specific rating
  Future<void> _deleteRating(String ratingId) async {
    try {
      await FirebaseFirestore.instance.collection('Ratings').doc(ratingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting rating: $e')),
      );
    }
  }

  // Method to edit a rating
  Future<void> _editRating(String ratingId, int currentRating) async {
    TextEditingController ratingController = TextEditingController(text: currentRating.toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Rating'),
          content: TextField(
            controller: ratingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter new rating (1-5)"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                try {
                  int newRating = int.parse(ratingController.text);
                  if (newRating < 1 || newRating > 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid rating between 1 and 5')),
                    );
                    return;
                  }

                  // Update the rating in Firestore
                  await FirebaseFirestore.instance.collection('Ratings').doc(ratingId).update({
                    'rating': newRating,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rating updated successfully')),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating rating: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Method to calculate average rating
  Future<double> _calculateAverageRating(String accommodationId) async {
    QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
        .collection('Ratings')
        .where('accommodations_id', isEqualTo: accommodationId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in ratingsSnapshot.docs) {
      total += (doc.data()! as Map<String, dynamic>)['rating'] ?? 0;
    }
    return total / ratingsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text(
          'Accommodation Manager',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _accommodationStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                String accommodationName = data['accommodationText'] ?? 'Unknown Accommodation';

                return ExpansionTile(
                  title: Text(accommodationName),
                  subtitle: FutureBuilder<double>(
                    future: _calculateAverageRating(document.id),
                    builder: (BuildContext context, AsyncSnapshot<double> averageSnapshot) {
                      if (averageSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Average Rating: loading...');
                      }
                      return Text('Average Rating: ${averageSnapshot.data!.toStringAsFixed(1)}');
                    },
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _ratingsStream(document.id),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> ratingsSnapshot) {
                        if (ratingsSnapshot.hasError) {
                          return Center(child: Text('Something went wrong while loading ratings'));
                        }

                        if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (ratingsSnapshot.data!.docs.isEmpty) {
                          return ListTile(
                            title: Text('No ratings available for this accommodation'),
                          );
                        }

                        return Column(
                          children: ratingsSnapshot.data!.docs.map((DocumentSnapshot ratingDocument) {
                            Map<String, dynamic> ratingData = ratingDocument.data()! as Map<String, dynamic>;
                            String ratingId = ratingDocument.id;
                            int ratingValue = ratingData['rating'] ?? 0;

                            return ListTile(
                              title: Text('Rating: $ratingValue'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editRating(ratingId, ratingValue), // Edit rating
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Confirm deletion
                                      bool? confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Deletion'),
                                            content: Text('Are you sure you want to delete this rating?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () => Navigator.of(context).pop(false),
                                              ),
                                              TextButton(
                                                child: Text('Delete'),
                                                onPressed: () => Navigator.of(context).pop(true),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmed == true) {
                                        _deleteRating(ratingId);
                                      }
                                    }, // Delete rating
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
