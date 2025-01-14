import 'dart:io';
import 'dart:typed_data'; // Import this for Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For uploading images to Firebase Storage
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import this to check for web

import '../App_thime.dart';

class AddAccommodationPage extends StatefulWidget {
  final String Username;
  final String userId;

  const AddAccommodationPage({
    super.key,
    required this.userId,
    required this.Username,
  });

  @override
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final TextEditingController _accommodationTextController = TextEditingController();
  final TextEditingController _accommodationTypeController = TextEditingController();
  final TextEditingController _accommodationDateController = TextEditingController();
  final TextEditingController _accommodationDetailsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController(); // Controller for location link

  DateTime? _selectedDate;
  String? _selectedCity;
  String? _selectedPriceUnit;
  List<String> _priceUnits = ['Day', 'Week', 'Month', 'Year']; // Price units
  List<String> _cities = [];

  File? _image; // To store the selected image (mobile)
  Uint8List? _webImage; // To store the selected image (web)
  String? _uploadedImageUrl; // To store the uploaded image URL

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  void _fetchCities() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Cities').get();
    setState(() {
      _cities = snapshot.docs.map((doc) => doc['city_name'] as String).toList(); // Change 'city_name' based on your Firestore structure
    });
  }

  Future<void> _addAccommodation() async {
    if (_accommodationTextController.text.isEmpty ||
        _selectedCity == null ||
        _selectedDate == null ||
        _phoneController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedPriceUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.')));
      return; // Exit early
    }

    String imageUrl = _uploadedImageUrl ?? '';

    await FirebaseFirestore.instance.collection('accommodations').add({
      'userid': widget.userId,
      'accommodationText': _accommodationTextController.text,
      'accommodationType': _accommodationTypeController.text,
      'accommodationDetails': _accommodationDetailsController.text,
      'accommodationDate': _selectedDate,
      'city': _selectedCity,
      'imageUrl': imageUrl,
      'phone': _phoneController.text, // Add phone number
      'price': double.tryParse(_priceController.text) ?? 0.0, // Add price, default to 0.0 if invalid
      'priceUnit': _selectedPriceUnit, // Store the price unit
      'locationLink': _locationLinkController.text, // Add location link
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accommodation added successfully!')));

    // Clear the text fields
    _accommodationTextController.clear();
    _accommodationTypeController.clear();
    _accommodationDetailsController.clear();
    _phoneController.clear();
    _priceController.clear();
    _locationLinkController.clear(); // Clear the location link field
    setState(() {
      _selectedCity = null; // Reset city selection
      _image = null; // Reset selected image
      _webImage = null; // Reset web image
      _uploadedImageUrl = null; // Reset uploaded image URL
      _selectedDate = null; // Reset selected date
      _selectedPriceUnit = null; // Reset selected price unit
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Set the selected date
        _accommodationDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format date for display
      });
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Image picking for web
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Read the image bytes asynchronously
        final Uint8List bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes.buffer.asUint8List(); // Store the selected web image
        });

        if (_webImage != null) {
          try {
            // Upload the image to Firebase Storage
            final storageRef = FirebaseStorage.instance.ref().child('accommodation_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
            final uploadTask = storageRef.putData(_webImage!);

            final TaskSnapshot downloadUrl = await uploadTask;
            final String url = await downloadUrl.ref.getDownloadURL();

            setState(() {
              _uploadedImageUrl = url; // Store the uploaded image URL
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
          }
        }
      }
    } else {
      // Image picking for mobile (Android/iOS)
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Store the selected image
        });
        if (_image != null) {
          try {
            // Upload the image to Firebase Storage
            final storageRef = FirebaseStorage.instance.ref().child('accommodation_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
            final uploadTask = storageRef.putFile(_image!);

            final TaskSnapshot downloadUrl = await uploadTask;
            final String url = await downloadUrl.ref.getDownloadURL();

            setState(() {
              _uploadedImageUrl = url; // Store the uploaded image URL
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeae9),
      appBar: AppBar(
        title: Text(
          'Welcome ${widget.Username}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: lastColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display image based on platform
              if (kIsWeb && _webImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _webImage!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, size: 50),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  backgroundColor: lastColor, // Custom button color
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // Accommodation Text
              _buildInputField(_accommodationTextController, 'Accommodation Text'),
              const SizedBox(height: 10),

              // Accommodation Type
              _buildInputField(_accommodationTypeController, 'Accommodation Type'),
              const SizedBox(height: 10),

              // Accommodation Date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildInputField(
                    _accommodationDateController,
                    'Accommodation Date',
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // City Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select City',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCity,
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Accommodation Details
              _buildInputField(_accommodationDetailsController, 'Accommodation Details'),
              const SizedBox(height: 10),

              // Phone Number
              _buildInputField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),

              // Price
              _buildInputField(_priceController, 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 10),

              // Price Unit Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Price Unit',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPriceUnit,
                items: _priceUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriceUnit = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Location Link
              _buildInputField(_locationLinkController, 'Location Link'),
              const SizedBox(height: 10),

              // Submit Button
              ElevatedButton(
                onPressed: _addAccommodation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  backgroundColor: lastColor,
                ),
                child: const Text(
                  'Add Accommodation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
