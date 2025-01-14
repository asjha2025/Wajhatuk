import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../App_thime.dart';

class AddPlacePage extends StatefulWidget {
  final String cityId; // Receive city ID from AddCity page
  final String placeType; // Type of place (e.g., restaurant, park, etc.)
  final String userId;

  AddPlacePage({required this.cityId, required this.placeType, required this.userId});

  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _placeDetailsController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();

  File? _placeImageFile;
  Uint8List? _placeImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        // For Flutter Web, use Uint8List
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _placeImageBytes = imageBytes;
        });
      } else {
        // For Android/iOS, use File
        setState(() {
          _placeImageFile = File(pickedFile.path);
        });
      }
    }
  }

  // Function to add place to Firestore
  Future<void> _addPlaceToFirestore() async {
    if (_placeNameController.text.isEmpty ||
        _placeDetailsController.text.isEmpty ||
        _locationLinkController.text.isEmpty ||
        (_placeImageFile == null && _placeImageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    // Show loading indicator while uploading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      String imageUrl = '';
      if (kIsWeb) {
        // Upload image to Firebase Storage for Web
        String fileName = 'places/${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putData(_placeImageBytes!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        // Upload image to Firebase Storage for Android/iOS
        String fileName = 'places/${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(_placeImageFile!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Add place data to Firestore
      await FirebaseFirestore.instance.collection('Places').add({
        'user_id': widget.userId,
        'city_id': widget.cityId,
        'place_type': widget.placeType,
        'place_name': _placeNameController.text,
        'place_details': _placeDetailsController.text,
        'location_link': _locationLinkController.text,
        'image_url': imageUrl,
        'created_at': Timestamp.now(),
      });

      Navigator.of(context).pop(); // Remove loading indicator
      Navigator.of(context).pop(); // Return to previous page
      print("Place Added");

    } catch (e) {
      Navigator.of(context).pop(); // Remove loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add place: $e')),
      );
    }
  }

  // Function to show options to pick image from gallery or camera
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: lastColor),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: lastColor),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.placeType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.0),

              // Display image based on platform
              kIsWeb
                  ? (_placeImageBytes == null
                  ? Text('No image selected.')
                  : Image.memory(
                _placeImageBytes!,
                height: 200,
              ))
                  : (_placeImageFile == null
                  ? Text('No image selected.')
                  : Image.file(
                _placeImageFile!,
                height: 200,
              )),
              ElevatedButton(
                onPressed: _showImageSourceOptions,
                child: Text('Upload Image'),
              ),
              SizedBox(height: 16.0),

              TextField(
                controller: _placeNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _placeDetailsController,
                decoration: InputDecoration(labelText: 'Details'),
                maxLines: 3,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _locationLinkController,
                decoration: InputDecoration(labelText: 'Location Link (Google Maps URL)'),
              ),

              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addPlaceToFirestore,
                child: Text('Add Place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
