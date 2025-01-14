import 'package:flutter/material.dart';
import 'package:wajhatuk/Admin/add_placses.dart';

import 'Places_Page.dart';

class AdminPage extends StatefulWidget {
  final String cityId; // Receive city ID from AddCity page
  final String name; // Receive city ID from AddCity page
final String userId;
  AdminPage({required this.cityId, required this.name,required this.userId});
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildGridView(),
          buildGridView(),
          buildGridView(),
          buildGridView(),
          buildGridView(),
          buildGridView(),
          buildGridView(),
        ],
      ),
    );
  }

  Widget buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: <Widget>[
          InkWell(
              child: buildGridItem('Restaurants'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowPlacesPage(
                            cityId: widget.cityId, placeType: 'Restaurants',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Cafes'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowPlacesPage(cityId: widget.cityId, placeType: 'Cafes',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Pharmacy'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowPlacesPage(cityId: widget.cityId, placeType: 'Pharmacy',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Hospital'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowPlacesPage(cityId: widget.cityId, placeType: 'Hospital',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Mail'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowPlacesPage(cityId: widget.cityId, placeType: 'Mail',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Season'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowPlacesPage(cityId: widget.cityId, placeType: 'Season',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Touristic Monument'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowPlacesPage(
                            cityId: widget.cityId, placeType: 'Touristic Monument',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Delivery and Uber'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowPlacesPage(
                            cityId: widget.cityId, placeType: 'Delivery and Uber',userId:widget.userId)));
              }),
          InkWell(
              child: buildGridItem('Traditional FoodPlace'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowPlacesPage(
                            cityId: widget.cityId, placeType: 'Traditional FoodPlace',userId:widget.userId)));
              }),
        ],
      ),
    );
  }

  Widget buildGridItem(String title) {
    return Card(

      color: Color(0xff513d78),
      elevation: 2,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
