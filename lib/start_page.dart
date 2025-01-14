import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:wajhatuk/login_page.dart';
import 'package:wajhatuk/register_page.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'App_thime.dart';

class WajhatukStartPage extends StatelessWidget {
  // final List<Map<String, String>> landmarks = [
  //
  //   {"name": "قصر المصمك", "image": "assets/musmak_palace.png"},
  //   {"name": "جبل الفيل", "image": "assets/elephant_rock.png"},
  //   {"name": "مدائن صالح", "image": "assets/madain_salih.png"},
  //   {"name": "برج المملكة", "image": "assets/kingdom_tower.png"},
  //   {"name": "الدرعية", "image": "assets/diriyah.png"},
  // ];
  //
  // final List<Map<String, String>> touristCities = [
  //   {"city": "الرياض", "image": "assets/riyadh.png"},
  //   {"city": "العلا", "image": "assets/alula.png"},
  //   {"city": "جدة", "image": "assets/jeddah.png"},
  //   {"city": "الطائف", "image": "assets/taif.png"},
  //   {"city": "المنطقة الشرقية", "image": "assets/eastern_region.png"},
  // ];

  final List<Map<String, String>> landmarks = [
    {
      "name_ar": "قصر المصمك",
      "name_en": "Masmak Fortress",
      "image": "assets/musmak_palace.png"
    },
    {
      "name_ar": "جبل الفيل",
      "name_en": "Elephant Rock",
      "image": "assets/elephant_rock.png"
    },
    {
      "name_ar": "مدائن صالح",
      "name_en": "Madain Salih",
      "image": "assets/madain_salih.png"
    },
    {
      "name_ar": "برج المملكة",
      "name_en": "Kingdom Tower",
      "image": "assets/kingdom_tower.png"
    },
    {
      "name_ar": "الدرعية",
      "name_en": "Diriyah",
      "image": "assets/diriyah.png"
    },
  ];

  final List<Map<String, String>> touristCities = [
    {
      "name_ar": "الرياض",
      "name_en": "Riyadh",
      "image": "assets/riyadh.png"
    },
    {
      "name_ar": "العلا",
      "name_en": "AlUla",
      "image": "assets/alula.png"
    },
    {
      "name_ar": "جدة",
      "name_en": "Jeddah",
      "image": "assets/jeddah.png"
    },
    {
      "name_ar": "الطائف",
      "name_en": "Taif",
      "image": "assets/taif.png"
    },
    {
      "name_ar": "المنطقة الشرقية",
      "name_en": "Eastern Province",
      "image": "assets/eastern_region.png"
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor, // Saudi Arabia's color

      appBar: AppBar(
        title: Text(
          Provider.of<LanguageProvider>(context).locale.languageCode == 'ar'
              ? 'Wajhatuk - وجهتك'
              : 'Wajhatuk - Your Destination',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lastColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: mainColor),
            tooltip: 'Change Language',
            onPressed: () {
              Provider.of<LanguageProvider>(context, listen: false)
                  .switchLanguage();
            },
          ),
          IconButton(
            icon: Icon(Icons.login, color: mainColor),
            tooltip: 'Login',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.app_registration, color: mainColor),
            tooltip: 'Register',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  Provider.of<LanguageProvider>(context).locale.languageCode == 'ar'
                      ? 'مرحباً بكم في وجهتك!'
                      : 'Welcome to Your Destination!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: lastColor,
                  ),
                ),
                SizedBox(height: 16),
                Image.asset('assets/logo.png', width: 300),
                SizedBox(height: 16),

                SizedBox(height: 20),

                // Landmarks section slider
                Text(
                  Provider.of<LanguageProvider>(context).locale.languageCode == 'ar'
                ?  'أبرز المعالم السياحية في السعودية'
                  :'Top Tourist Attractions in Saudi Arabia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: lastColor,
                  ),
                ),
                SizedBox(height: 10),
                _buildLandmarkSlider(context),

                SizedBox(height: 20),

                // Tourist cities section slider
                Text(
                  Provider.of<LanguageProvider>(context).locale.languageCode == 'ar'
                  ?'أبرز الوجهات السياحية في السعودية'
                  :'Top tourist destinations in Saudi Arabia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: lastColor,
                  ),
                ),
                SizedBox(height: 10),
                _buildTouristCitiesSlider(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the landmarks slider
  Widget _buildLandmarkSlider(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: landmarks.map((landmark) {
        return Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                Expanded(
                  child: Image.asset(
                    landmark['image']!,
                    width: 300,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  languageCode == 'ar' ? landmark['name_ar']! : landmark['name_en']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lastColor,
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  // Build the tourist cities slider
  Widget _buildTouristCitiesSlider(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).locale.languageCode;
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: touristCities.map((city) {
        return Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
            Expanded(
            child:Image.asset(
                  city['image']!,
                  width: 300,
                  height: 180,
                  fit: BoxFit.cover,
                )),
                SizedBox(height: 10),
                Text(
                  languageCode == 'ar' ? city['name_ar']! : city['name_en']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lastColor,
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}
