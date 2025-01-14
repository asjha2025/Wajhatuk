import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wajhatuk/Tourest/show_Place.dart';

import '../App_thime.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> _cities = [];
  bool isLoading = true; // حالة التحميل
  int _selectedIndex = 0; // لتتبع الصفحة الحالية

  @override
  void initState() {
    super.initState();
    _fetchCities(); // جلب المدن عند تحميل الصفحة
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchCities() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Cities').get();
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, String>> cities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'city_name': data.containsKey('city_name')
                ? data['city_name'] as String
                : 'Unknown',
            'city_id': doc.id,
          };
        }).toList();

        setState(() {
          _cities = cities;
          _tabController = TabController(length: _cities.length, vsync: this);
          isLoading = false; // إنهاء التحميل بعد جلب البيانات
        });
      } else {
        throw 'No cities found';
      }
    } catch (e) {
      print("Error fetching cities: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cities: ${e.toString()}")),
      );
      setState(() {
        isLoading = false; // إنهاء التحميل في حال وجود خطأ
      });
    }
  }

  // لتحديث الصفحة المختارة
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lastColor,
        title: Text(
          'Tour in KSA',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: mainColor),
          textAlign: TextAlign.center,
        ),
        bottom: isLoading
            ? null
            : _selectedIndex == 0 && _cities.isNotEmpty
            ? TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _cities.map((city) {
            return Tab(
              child: Text(
                city['city_name']!,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainColor),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        )
            : null,
      ),
      body: _selectedIndex == 0
          ? (isLoading
          ? Center(child: CircularProgressIndicator())
          : _cities.isNotEmpty
          ? TabBarView(
        controller: _tabController,
        children: _cities.map((city) {
          return CityGridView(
              city: city['city_name']!,
              cityId: city['city_id']!,
              userId: widget.userId);
        }).toList(),
      )
          : Center(child: Text('No cities available')))
          : ProfilePage(userId: widget.userId), // عرض صفحة البروفايل عند اختيارها
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff513d78),
        onTap: _onItemTapped, // تحديث الصفحة عند الضغط
      ),
    );
  }
}

// صفحة الملف الشخصي

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _passwordController.text = userData['password'] ?? ''; // Usually store hashed
      });
    }
  }

  Future<void> _updateUserProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Setting',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor),),
        backgroundColor: lastColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with user image if available
              ),
              SizedBox(height: 20),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),

              // Family Name Field

              SizedBox(height: 10),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10),

              // Phone Field

              SizedBox(height: 10),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 10),

              // Bio Field

              SizedBox(height: 20),

              // Update Button
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Update', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainColor),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lastColor, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// CityGridView widget
class CityGridView extends StatelessWidget {
  final String city;
  final String cityId;
  final String userId;

  const CityGridView(
      {Key? key,
        required this.city,
        required this.cityId,
        required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> gridItems = [
      {'title': 'Mail', 'image': 'assets/malls.png', 'id': 'malls_doc_id','cityId':cityId},
      {'title': 'Cafes', 'image': 'assets/cafes.png', 'id': 'cafes_doc_id','cityId':cityId},
      {'title': 'Pharmacy', 'image': 'assets/Pharmacy.png', 'id': 'pharmacy_doc_id','cityId':cityId},
      {'title': 'Hospital', 'image': 'assets/Hospital.png', 'id': 'hospital_doc_id','cityId':cityId},
      {'title': 'Season', 'image': 'assets/seasonal_events.png', 'id': 'season_doc_id','cityId':cityId},
      {'title': 'Delivery and Uber', 'image': 'assets/Delivery_Link.png', 'id': 'delivery_link_doc_id','cityId':cityId},
      {'title': 'Touristic Monument', 'image': 'assets/tourist_attractions.png', 'id': 'touristic_monument_doc_id','cityId':cityId},
      {'title': 'Restaurants', 'image': 'assets/restaurants.png', 'id': 'restaurants_doc_id','cityId':cityId},
      {'title': 'Traditional FoodPlace', 'image': 'assets/Traditional_FoodPlace.png', 'id': 'traditional_foodplace_doc_id','cityId':cityId},
      {'title': 'Accommodations', 'image': 'assets/Accommodations.png', 'id': 'accommodations_doc_id','cityId':cityId},
    ];

    return  Expanded(
        child:Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: gridItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          var item = gridItems[index];
          return Expanded(
            child: GridItem(
              title: item['title']!,
              imagePath: item['image']!,
              documentId: item['id']!,
              cityId: cityId,
              userId: userId,
            ),
          );
        },
      ),)
    );
  }
}

// GridItem widget
class GridItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String documentId;
  final String cityId;
  final String userId;

  const GridItem(
      {Key? key,
        required this.title,
        required this.imagePath,
        required this.documentId,
        required this.cityId,
        required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        color: mainColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Image.asset(imagePath, height: 120, width: 150)),
              SizedBox(height: 10),
        Expanded(child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: lastColor,
                ),
                textAlign: TextAlign.center,
              ),)
            ],
          ),
        ),
      ),
      onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PlaceDetailPage(
                      placeType: title,
                      cityId: cityId,
                      userId: userId,
                    )),
          );
        }

    );
  }
}
