import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../App_thime.dart';
import 'accommodation.dart';

class AccommodationListPage extends StatelessWidget {
  final String userId;
  final String Username;

  AccommodationListPage({required this.userId, required this.Username});

  @override
  Widget build(BuildContext context) {
    final CollectionReference accommodationCollection = FirebaseFirestore.instance.collection('accommodations');
    Query filteredQuery = accommodationCollection.where('userid', isEqualTo: userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text('Your Accommodations',style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: mainColor),
          textAlign: TextAlign.center,),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: filteredQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(
              child: Text('No accommodations found for this user.'),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
              String docId = documents[index].id;

              // Default accommodation image if not provided
              String imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150'; // Placeholder image URL
              bool isActive = data['status'] == 'Active'; // Status: 'Active' or 'Inactive'

              return Center(
                child: Card(
                  color: mainColor,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),

                  child:   Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   ListTile(
                  title: Image.network(
                    imageUrl,
                    width: 400,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Title: ${data['accommodationText']}',
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),
                          SizedBox(width: 50),

                          Text(
                            'Type: ${data['accommodationType']}',
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4), // إضافة مساحة بين الصفوف
                      Text(
                        'Details: ${data['accommodationDetails']}',
                        style: TextStyle(
                          fontSize: 18, // حجم الخط
                          fontWeight: FontWeight.bold, // جعل الخط غامق
                          color: Colors.black, // اللون الأسود
                        ),
                      ),
                      SizedBox(height: 4),

                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Date: ${_formatDate(data['accommodationDate'])}', // تنسيق التاريخ
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),
                          SizedBox(width: 50),

                          Text(
                            'City: ${data['city']}',
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),


                        ],
                      ),

                      SizedBox(height: 5),
                      Row(

                        children: [
                          Text(
                            'Phone: ${data['phone']}',
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),
                          SizedBox(width: 50),

                          Text(
                            'Price: ${data['price']}',
                            style: TextStyle(
                              fontSize: 18, // حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط غامق
                              color: Colors.black, // اللون الأسود
                            ),
                          ),
                          SizedBox(width: 50),


                        ],

                      ),
                      SizedBox(height: 30),
                Center(
                  child: Text(
                    'locationLink: ${data['locationLink']}',
                    style: TextStyle(
                      fontSize: 18, // حجم الخط
                      fontWeight: FontWeight.bold, // جعل الخط غامق
                      color: Colors.black, // اللون الأسود
                    ),
                  ),
                ),
                                    SizedBox(height: 30),
                                    Center(
                child: Text(
                  'Status: ${data['status']}',
                  style: TextStyle(
                    fontSize: 18, // حجم الخط
                    fontWeight: FontWeight.bold, // جعل الخط غامق
                    color: Colors.black, // اللون الأسود
                  ),
                ),
                                    ),
                    ],
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        onPressed: () {
                          _toggleStatus(docId, !isActive); // Toggle status
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditAccommodationDialog(context, docId, data);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, docId);
                        },
                      ),
                    ],
                  ),
                ],),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddAccommodationPage(userId: userId, Username: Username)));
        },
      ),
    );
  }

  // Toggle status between 'Active' and 'Inactive'
  void _toggleStatus(String docId, bool isActive) {
    final CollectionReference accommodationCollection = FirebaseFirestore.instance.collection('accommodations');
    accommodationCollection.doc(docId).update({
      'status': isActive ? 'Active' : 'Inactive',
    });
  }

  void _showEditAccommodationDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController accommodationTextController = TextEditingController(text: data['accommodationText']);
    final TextEditingController accommodationTypeController = TextEditingController(text: data['accommodationType']);
    final TextEditingController cityController = TextEditingController(text: data['city']);
    final TextEditingController statusController = TextEditingController(text: data['status']);
    // Convert price from int to String
    final TextEditingController priceController = TextEditingController(
      text: data['price']?.toString() ?? '', // Convert int to String and handle null safety
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          title: Text('Edit Accommodation'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: accommodationTextController,
                  decoration: InputDecoration(labelText: 'Accommodation Text'),
                ),
                TextField(
                  controller: accommodationTypeController,
                  decoration: InputDecoration(labelText: 'Accommodation Type'),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number, // Ensure numeric keyboard for price
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: Text('Save Changes'),
              onPressed: () {
                _updateAccommodation(docId, {
                  'accommodationText': accommodationTextController.text,
                  'accommodationType': accommodationTypeController.text,
                  'city': cityController.text,
                  'status': statusController.text,
                  'price': int.tryParse(priceController.text) ?? 0, // Convert back to int
                });
                Navigator.of(context).pop(); // Close the dialog after saving
              },
            ),
          ],
        );
      },
    );
  }

  // Delete accommodation (no changes needed)
  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Accommodation'),
          content: Text('Are you sure you want to delete this accommodation?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: lastColor)),
              onPressed: () {
                _deleteAccommodation(docId); // Delete the accommodation
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Update accommodation details (no changes needed)
  Future<void> _updateAccommodation(String docId, Map<String, dynamic> updatedData) async {
    final CollectionReference accommodationCollection = FirebaseFirestore.instance.collection('accommodations');
    try {
      await accommodationCollection.doc(docId).update(updatedData);
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // Delete accommodation (no changes needed)
  Future<void> _deleteAccommodation(String docId) async {
    final CollectionReference accommodationCollection = FirebaseFirestore.instance.collection('accommodations');
    try {
      await accommodationCollection.doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate()); // تحويل Timestamp إلى DateTime
    } else if (date is DateTime) {
      return DateFormat('yyyy-MM-dd').format(date); // إذا كان بالفعل DateTime
    } else {
      return ''; // في حال كانت القيمة غير صالحة
    }
  }
}
