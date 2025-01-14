import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../App_thime.dart';

class PlaceDetailPage extends StatefulWidget {
  final String placeType; // نوع المكان
  final String cityId; // ID المدينة
  final String userId; // ID المستخدم

  PlaceDetailPage({
    required this.placeType,
    required this.cityId,
    required this.userId,
  });

  @override
  _PlaceDetailPageState createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  bool _isAscending = true; // Track sort order

  List<Map<String, dynamic>> placeData = [];
  List<Map<String, dynamic>> accommodationsData = [];
  List<Map<String, dynamic>> DelveryData = [];

  Map<String, double> placeRatings = {};
  Map<String, double> delveryRatings = {};
  Map<String, double> accommodationRatings = {};
  String? cityName;
  String? cityName1;
  bool isLoading = true; // حالة تحميل البيانات
  int userRating = 0; // لتخزين تقييم المستخدم كعدد صحيح
// دالة initState تقوم بتهيئة الحالة عند تحميل الويدجت لأول مرة
  @override
  void initState() {
    super.initState();
    _fetchData(); // استدعاء الدالة لجلب البيانات من Firestore
  }

// دالة fetchData لجلب البيانات من عدة مصادر في وقت واحد باستخدام Future.wait
  Future<void> _fetchData() async {
    setState(
        () => isLoading = true); // ضبط isLoading إلى true لإظهار حالة التحميل
    try {
      await Future.wait([
        _fetchPlaceData(), // جلب بيانات الأماكن
        _fetchCityName(), // جلب اسم المدينة
        _FetchAccommodations(), // جلب بيانات أماكن الإقامة
        _fetchDelveryData(), // جلب بيانات خدمات التوصيل
      ]);
    } catch (e) {
      // يمكنك تسجيل الخطأ هنا
    } finally {
      setState(() => isLoading = false); // ضبط isLoading إلى false عند الانتهاء
    }
  }

// دالة fetchPlaceData لجلب بيانات الأماكن من Firestore
  Future<void> _fetchPlaceData() async {
    try {
      QuerySnapshot snapshot;

      // جلب البيانات من مجموعة "Places" وتصفية حسب نوع المكان ومعرف المدينة
      snapshot = await FirebaseFirestore.instance
          .collection('Places')
          .where('place_type', isEqualTo: widget.placeType)
          .where('city_id', isEqualTo: widget.cityId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          // معالجة البيانات وحفظها في قائمة placeData
          placeData = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'userRating': 0, // إضافة حقل لتقييم المستخدم
              'location_link':
                  data['location_link'] ?? '', // تعيين قيمة افتراضية للرابط
              'doc': doc.id, // إضافة معرف الوثيقة
            };
          }).toList();
        });

        await _fetchRatingsForAllPlaces(); // جلب تقييمات كل مكان
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place details: $e')),
      );
    }
  }

// دالة fetchCityName لجلب اسم المدينة بناءً على معرف المدينة
  Future<void> _fetchCityName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Cities')
          .doc(widget.cityId)
          .get();

      if (snapshot.exists) {
        setState(() {
          cityName = snapshot['city_name']; // تعيين اسم المدينة
        });
      } else {
        throw 'المدينة غير موجودة';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب اسم المدينة: $e')),
      );
    }
  }

// دالة FetchAccommodations لجلب بيانات أماكن الإقامة بناءً على المدينة
  Future<void> _FetchAccommodations() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Cities')
        .doc(widget.cityId)
        .get();
    cityName1 = snapshot['city_name'];

    QuerySnapshot snapshotA;
    try {
      snapshotA = await FirebaseFirestore.instance
          .collection('accommodations')
          .where('city', isEqualTo: cityName1)
          .where('status', isEqualTo: 'Active')
          .get();

      if (snapshotA.docs.isNotEmpty) {
        setState(() {
          // معالجة البيانات وحفظها في قائمة accommodationsData
          accommodationsData = snapshotA.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'userRating': 0, // إضافة حقل لتقييم المستخدم
              'location_link':
                  data['location_link'] ?? '', // تعيين قيمة افتراضية للرابط
              'doc': doc.id, // إضافة معرف الوثيقة
            };
          }).toList();
        });
      }
      await _fetchRatingsForAllaccommodations(); // جلب تقييمات أماكن الإقامة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place details: $e')),
      );
    }
  }
  // دالة fetchDelveryData لجلب بيانات خدمات التوصيل بناءً على نوع المكان

  Future<void> _fetchDelveryData() async {
    try {
      QuerySnapshot snapshot2;

      // جلب البيانات من مجموعة "Places" وتصفية حسب نوع المكان "Delivery and Uber"
      snapshot2 = await FirebaseFirestore.instance
          .collection('Places')
          .where('place_type', isEqualTo: 'Delivery and Uber')
          .get();

      if (snapshot2.docs.isNotEmpty) {
        setState(() {
          // معالجة البيانات وحفظها في قائمة DelveryData
          DelveryData = snapshot2.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'userRating': 0, // إضافة حقل لتقييم المستخدم
              'location_link':
                  data['location_link'] ?? '', // تعيين قيمة افتراضية للرابط
              'doc': doc.id, // إضافة معرف الوثيقة
            };
          }).toList();
        });

        await _fetchRatingsForAllPlaces(); // جلب تقييمات الأماكن
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place details: $e')),
      );
    }
  }

// دالة fetchRatingsForAllPlaces لحساب متوسط التقييمات لكل مكان
  Future<void> _fetchRatingsForAllPlaces() async {
    try {
      for (var place in placeData) {
        String placeDocumentId = place['doc'];

        // جلب التقييمات من مجموعة "Ratings" بناءً على معرف الوثيقة
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Ratings')
            .where('place_id', isEqualTo: placeDocumentId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<int> ratings = snapshot.docs
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['rating'] as int)
              .toList();

          double averageRating = ratings.isNotEmpty
              ? ratings.reduce((a, b) => a + b) / ratings.length
              : 0.0;

          // تخزين متوسط التقييم لكل مكان
          setState(() {
            placeRatings[placeDocumentId] = averageRating;
          });
        } else {
          // إذا لم يكن هناك أي تقييمات للمكان، سيتم تعيين 0
          setState(() {
            placeRatings[placeDocumentId] = 0.0;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب التقييمات: $e')),
      );
    }
  }

  Future<void> _fetchRatingsForDelvery() async {
    try {
      for (var Delvery in DelveryData) {
        String DelveryDocumentId = Delvery['doc'];

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Ratings')
            .where('place_id',
                isEqualTo:
                    DelveryDocumentId) // استخدام Document ID بدلاً من place_id
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<int> ratings = snapshot.docs
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['rating'] as int)
              .toList();

          double averageRating1 = ratings.isNotEmpty
              ? ratings.reduce((a, b) => a + b) / ratings.length
              : 0.0;

          // تخزين متوسط التقييم لكل مكان
          setState(() {
            delveryRatings[DelveryDocumentId] = averageRating1;
          });
        } else {
          // إذا لم يكن هناك أي تقييمات للمكان، سيتم تعيين 0
          setState(() {
            delveryRatings[DelveryDocumentId] = 0.0;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب التقييمات: $e')),
      );
    }
  }

  Future<void> _fetchRatingsForAllaccommodations() async {
    try {
      for (var accommodations in accommodationsData) {
        String accommodationsDocumentId = accommodations['doc'];

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Ratings')
            .where('accommodations_id',
                isEqualTo:
                    accommodationsDocumentId) // استخدام Document ID بدلاً من place_id
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<int> ratings = snapshot.docs
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['rating'] as int)
              .toList();

          double averageRating = ratings.isNotEmpty
              ? ratings.reduce((a, b) => a + b) / ratings.length
              : 0.0;

          // تخزين متوسط التقييم لكل مكان
          setState(() {
            accommodationRatings[accommodationsDocumentId] = averageRating;
          });
        } else {
          // إذا لم يكن هناك أي تقييمات للمكان، سيتم تعيين 0
          setState(() {
            accommodationRatings[accommodationsDocumentId] = 0.0;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب التقييمات: $e')),
      );
    }
  }

  // تقديم تقييم للمكان
  Future<void> _submitRatingForPlace(int index) async {
    String placeDocumentId = placeData[index]['doc'];

    try {
      // Check if the user has already rated the place
      QuerySnapshot existingRating = await FirebaseFirestore.instance
          .collection('Ratings')
          .where('user_id', isEqualTo: widget.userId)
          .where('place_id', isEqualTo: placeDocumentId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // If a previous rating by the user is found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already rated this place')),
        );
        return; // Prevent the user from submitting a new rating
      }

      int rating = placeData[index]['userRating'];
      if (rating < 1 || rating > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose a valid rating')),
        );
        return;
      }

      // Show confirmation dialog
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Rating'),
            content: Text(
                'Are you sure you want to give a rating of $rating stars for this place?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context)
                    .pop(false), // Close the dialog and return false
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () => Navigator.of(context)
                    .pop(true), // Close the dialog and return true
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // If the rating is confirmed, submit it
        await FirebaseFirestore.instance.collection('Ratings').add({
          'user_id': widget.userId,
          'place_id': placeDocumentId,
          'rating': rating, // Use integer rating
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')),
        );

        // Fetch ratings again to update the UI
        await _fetchRatingsForAllPlaces();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  Future<void> _submitRatingForDelivery(int index) async {
    String placeDocumentId = DelveryData[index]['doc'];

    try {
      // Check if the user has already rated the delivery service
      QuerySnapshot existingRating = await FirebaseFirestore.instance
          .collection('Ratings')
          .where('user_id', isEqualTo: widget.userId)
          .where('place_id', isEqualTo: placeDocumentId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // If a previous rating by the user is found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You have already rated this delivery service')),
        );
        return; // Prevent the user from submitting a new rating
      }

      int rating = DelveryData[index]['userRating'];
      if (rating < 1 || rating > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose a valid rating')),
        );
        return;
      }

      // Show confirmation dialog
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Rating'),
            content: Text(
                'Are you sure you want to give a rating of $rating stars for this delivery service?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context)
                    .pop(false), // Close the dialog and return false
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () => Navigator.of(context)
                    .pop(true), // Close the dialog and return true
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // If the rating is confirmed, submit it
        await FirebaseFirestore.instance.collection('Ratings').add({
          'user_id': widget.userId,
          'place_id': placeDocumentId,
          'rating': rating, // Use integer rating
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')),
        );

        // Fetch ratings again to update the UI
        await _fetchRatingsForDelvery();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  Future<void> _submitRatingForAccommodation(int index) async {
    String accommodationDocumentId = accommodationsData[index]['doc'];

    try {
      // Check if the user has already rated the accommodation
      QuerySnapshot existingRating = await FirebaseFirestore.instance
          .collection('Ratings')
          .where('user_id', isEqualTo: widget.userId)
          .where('accommodations_id', isEqualTo: accommodationDocumentId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // If a previous rating by the user is found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already rated this accommodation')),
        );
        return; // Prevent the user from submitting a new rating
      }

      int rating = accommodationsData[index]['userRating'];
      if (rating < 1 || rating > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose a valid rating')),
        );
        return;
      }

      // Show confirmation dialog
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Rating'),
            content: Text(
                'Are you sure you want to give a rating of $rating stars for this accommodation?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context)
                    .pop(false), // Close the dialog and return false
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () => Navigator.of(context)
                    .pop(true), // Close the dialog and return true
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // If the rating is confirmed, submit it
        await FirebaseFirestore.instance.collection('Ratings').add({
          'user_id': widget.userId,
          'accommodations_id': accommodationDocumentId,
          'rating': rating, // Use integer rating
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')),
        );

        // Fetch ratings again to update the UI
        await _fetchRatingsForAllaccommodations();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  void _launchURL(String? locationLink) async {
    if (locationLink != null && locationLink.isNotEmpty) {
      if (await canLaunch(locationLink)) {
        await launch(locationLink);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('لم يمكن فتح رابط الخريطة، يرجى التحقق من الرابط')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط الخريطة غير متوفر')),
      );
    }
  }

  // عرض شاشة تحميل أثناء جلب البيانات
  Scaffold _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المكان'),
      ),
      body: Center(child: CircularProgressIndicator()), // عرض مؤشر التحميل
    );
  }

  // عرض رسالة خطأ عند عدم توفر البيانات
  Scaffold _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المكان'),
      ),
      body: Center(child: Text(message)), // عرض رسالة الخطأ
    );
  }

  Scaffold _buildDelveryScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text(
          '${DelveryData[0]['place_type']} ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView.builder(
        itemCount: DelveryData.length,
        itemBuilder: (context, index) {
          final Delvery = DelveryData[index];
          String DelveryDocumentId = Delvery['doc'];
          double averageRating1 = delveryRatings[DelveryDocumentId] ?? 0.0;

          return Card(
            color: mainColor,
            margin: EdgeInsets.all(8.0),
            elevation: 4, // Add elevation for shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center elements
                children: [
                  // Image
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(15), // Rounded image corners
                    child: Image.network(
                      Delvery['image_url'] ?? '',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Place Name
                  Text(
                    Delvery['place_name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Center text
                  ),
                  SizedBox(height: 8),

                  // Place Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      Delvery['place_details'],
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Colors.black87, // Dark text for better readability
                      ),
                      textAlign: TextAlign.center, // Center text
                    ),
                  ),
                  SizedBox(height: 16),

                  // Button to open Google Maps
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lastColor, // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    onPressed: () => _launchURL(Delvery['location_link']),
                    child: Text(
                      'View Link  ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Average Rating
                  Text(
                    'Average rating: ${averageRating1.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: lastColor,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Display rating stars for user input
                  _buildRatingDelveryStars(index),

                  // Submit rating button
                  TextButton(
                    onPressed: () => _submitRatingForDelivery(index),
                    child: Text(
                      'Confirm Evaluation',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lastColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // الشاشة الرئيسية مع وظيفة التقييم
// Main screen displaying details for each place with a comment feature
  Scaffold _buildDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text(
          '${placeData[0]['place_type']} In $cityName',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView.builder(
        itemCount: placeData.length,
        itemBuilder: (context, index) {
          final place = placeData[index];
          String placeDocumentId = place['doc'];
          double averageRating = placeRatings[placeDocumentId] ?? 0.0;

          return Card(
            color: mainColor,
            margin: EdgeInsets.all(8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display image of the place
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      place['image_url'] ?? '',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Display place name
                  Text(
                    place['place_name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Place details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      place['place_details'],
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Google Maps button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lastColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _launchURL(place['location_link']),
                    child: Text(
                      'View Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Display average rating
                  Text(
                    'Average rating: ${averageRating.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 16, color: lastColor),
                  ),
                  SizedBox(height: 8),

                  // Star rating for user input
                  _buildRatingStars(index),
                  SizedBox(height: 8),

                  // Comment icon to add a comment

                  // Button to submit rating
                  TextButton(
                    onPressed: () => _submitRatingForPlace(index),
                    child: Text(
                      'Confirm Evaluation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lastColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.comment, color: lastColor),
                    onPressed: () => _showCommentDialog(placeDocumentId),
                    tooltip: 'Add a comment',
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Show dialog to enter a comment
  void _showCommentDialog(String placeDocumentId) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter your comment here'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String comment = commentController.text.trim();
                if (comment.isNotEmpty) {
                  _saveCommentToDatabase(placeDocumentId, comment);
                }
                Navigator.of(context).pop(); // Close dialog after saving
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

// Function to save comment to the database
  void _saveCommentToDatabase(String placeDocumentId, String comment) async {
    // Add code here to save `comment` for the specified place ID in your database
    // For example, if using Firebase:
    await FirebaseFirestore.instance
        .collection('Places')
        .doc(placeDocumentId)
        .collection('comments')
        .add({
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Widget _buildRatingDelveryStars(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (starIndex) {
        return IconButton(
          icon: Icon(
            starIndex < DelveryData[index]['userRating']
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              DelveryData[index]['userRating'] =
                  starIndex + 1; // تعيين التقييم لهذا المكان
            });
          },
        );
      }),
    );
  }

  // عرض نجوم التقييم
  Widget _buildRatingStars(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (starIndex) {
        return IconButton(
          icon: Icon(
            starIndex < placeData[index]['userRating']
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              placeData[index]['userRating'] =
                  starIndex + 1; // تعيين التقييم لهذا المكان
            });
          },
        );
      }),
    );
  }

  Widget _buildRatingStarsAccommodation(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (starIndex) {
        return IconButton(
          icon: Icon(
            starIndex < accommodationsData[index]['userRating']
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              accommodationsData[index]['userRating'] =
                  starIndex + 1; // Set rating for this accommodation
            });
          },
        );
      }),
    );
  }

  void _sortAccommodationsByPrice({bool ascending = true}) {
    accommodationsData.sort((a, b) {
      double priceA = double.tryParse(a['price'].toString()) ?? 0.0;
      double priceB = double.tryParse(b['price'].toString()) ?? 0.0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
  }

  // Screen displaying a list of accommodations with sorting, details, and rating functionality
  Widget _buildAccommodationScreen() {
    // Sort accommodations by price when the screen is built
    _sortAccommodationsByPrice(ascending: _isAscending);

    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: Text(
            'Accommodations in $cityName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: lastColor,
        actions: [
          // Toggle sort order button for price sorting
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: mainColor,
            ),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending; // Toggle sort order
                _sortAccommodationsByPrice(ascending: _isAscending); // Re-sort
              });
            },
          ),
        ],
      ),
      // Build a list of accommodation items
      body: ListView.builder(
        itemCount: accommodationsData.length,
        itemBuilder: (context, index) {
          final accommodation = accommodationsData[index];
          String accommodationDocumentId = accommodation['doc'];
          double averageRating =
              accommodationRatings[accommodationDocumentId] ?? 0.0;

          return Card(
            color: mainColor,
            margin: EdgeInsets.all(8.0),
            elevation: 4, // Shadow effect for cards
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center elements
                children: [
                  // Displaying accommodation image with error handling
                  SizedBox(
                    height: 200, // Set a fixed height for the image
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15), // Rounded image corners
                      child: Image.network(
                        accommodation['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(child: Text('Image not available')),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Accommodation Name
                  Text(
                    accommodation['accommodationText'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Display Type of Accommodation
                  Text(
                    'Type: ${accommodation['accommodationType']}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Display Price with currency unit
                  Text(
                    'Price: ${accommodation['price']} ${accommodation['priceUnit']}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Display Phone Number and WhatsApp Icon for contact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Phone: ${accommodation['phone']}'),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final phoneNumber = accommodation['phone']
                              .replaceAll(RegExp(r'\D'), '');
                          if (phoneNumber.length == 9) {
                            // Check if valid 9-digit number and open WhatsApp
                            final whatsappUrl =
                                'https://wa.me/+966$phoneNumber';
                            _launchURL(whatsappUrl);
                          } else {
                            // Show error if phone number is invalid
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Invalid phone number')));
                          }
                        },
                        child: Image.asset(
                          'assets/whatsapp.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Display Accommodation Details
                  Text(
                    'Details: ${accommodation['accommodationDetails']}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // Google Maps Link Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lastColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _launchURL(accommodation['locationLink']),
                    child: Text(
                      'View Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Display Average Rating
                  Text(
                    'Average Rating: ${averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: lastColor,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Display Rating Stars for user input
                  _buildRatingStarsAccommodation(index),

                  // Submit Rating Button
                  TextButton(
                    onPressed: () {
                      _submitRatingForAccommodation(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Rating submitted!')));
                    },
                    child: Text(
                      'Submit Rating',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lastColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen(); // Show loading screen
    } else if (widget.placeType == 'Accommodations' &&
        accommodationsData.isNotEmpty) {
      return _buildAccommodationScreen(); // Show accommodations screen
    } else if (widget.placeType == 'Delivery and Uber' &&
        DelveryData.isNotEmpty) {
      return _buildDelveryScreen(); // Show accommodations screen
    } else if (placeData.isEmpty || accommodationsData.isEmpty) {
      return _buildErrorScreen(
          'No places available for this type'); // Show error screen
    } else {
      return _buildDetailScreen(); // Show main screen
    }
  }
}
