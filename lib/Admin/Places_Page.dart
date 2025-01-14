import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../App_thime.dart';
import 'add_placses.dart';

class ShowPlacesPage extends StatefulWidget {
  final String cityId;
  final String placeType;
  final String userId;
  ShowPlacesPage({required this.cityId, required this.placeType,required this.userId});

  @override
  _ShowPlacesPageState createState() => _ShowPlacesPageState();
}

class _ShowPlacesPageState extends State<ShowPlacesPage> {
  // Function to delete a place from Firestore
  Future<void> _deletePlace(String placeId) async {
    await FirebaseFirestore.instance.collection('Places').doc(placeId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Place deleted successfully')),
    );
  }



  Future<void> _editPlace(String placeId, String currentName, String currentDetails, String currentLink, String currentImageUrl) async {
    final TextEditingController _placeNameController = TextEditingController(text: currentName);
    final TextEditingController _placeDetailsController = TextEditingController(text: currentDetails);
    final TextEditingController _locationLinkController = TextEditingController(text: currentLink);

    File? _newPlaceImage;
    final ImagePicker _picker = ImagePicker();

    // Function to pick a new image from gallery or camera
    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _newPlaceImage = File(pickedFile.path);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Place'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _newPlaceImage == null
                    ? Image.network(currentImageUrl, height: 100, fit: BoxFit.cover)
                    : Image.file(_newPlaceImage!, height: 100, fit: BoxFit.cover),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery); // Allow user to pick a new image
                  },
                  child: Text('Change Image'),
                ),
                TextField(
                  controller: _placeNameController,
                  decoration: InputDecoration(labelText: 'Place Name'),
                ),
                TextField(
                  controller: _placeDetailsController,
                  decoration: InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                ),
                TextField(
                  controller: _locationLinkController,
                  decoration: InputDecoration(labelText: 'Location Link'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String updatedImageUrl = currentImageUrl; // Default to the existing image URL

                if (_newPlaceImage != null) {
                  // If a new image is picked, upload it to Firebase Storage
                  String fileName = 'places/${DateTime.now().millisecondsSinceEpoch}.png';
                  Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
                  UploadTask uploadTask = storageRef.putFile(_newPlaceImage!);
                  TaskSnapshot snapshot = await uploadTask;
                  updatedImageUrl = await snapshot.ref.getDownloadURL();
                }

                // Update the place data in Firestore
                await FirebaseFirestore.instance.collection('Places').doc(placeId).update({
                  'place_name': _placeNameController.text,
                  'place_details': _placeDetailsController.text,
                  'location_link': _locationLinkController.text,
                  'image_url': updatedImageUrl, // Update the image URL if changed
                });

                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Place updated successfully')),
                );
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _showDeleteDialog(String placeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this place?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deletePlace(placeId); // Call delete function
              },
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor, // Match color theme from your design

        title: Text('Places in ${widget.placeType}' ,style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor),
          textAlign: TextAlign.center,),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Places')
            .where('city_id', isEqualTo: widget.cityId)
            .where('place_type', isEqualTo: widget.placeType)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final places = snapshot.data!.docs;

          if (places.isEmpty) {
            return Center(child: Text('No places found for this city and type'));
          }

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final placeId = place.id;
              final placeName = place['place_name'];
              final placeDetails = place['place_details'];
              final locationLink = place['location_link'];
              final imageUrl = place['image_url'];

              return Card(
                child: ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(placeName),
                  subtitle: Text(placeDetails),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,color: lastColor),
                        onPressed: () {
                          _editPlace(
                            placeId,
                            placeName,
                            placeDetails,
                            locationLink,
                            imageUrl,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,color: lastColor),
                        onPressed: () {
                          _showDeleteDialog(placeId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: lastColor),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddPlacePage(
                      cityId: widget.cityId, placeType: widget.placeType,userId:widget.userId)));

        },
      ),
    );
  }
}
