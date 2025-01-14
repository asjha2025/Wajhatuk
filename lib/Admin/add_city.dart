import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wajhatuk/Admin/Admin_home.dart';
import 'package:wajhatuk/Admin/add_placses.dart';
import 'package:wajhatuk/App_thime.dart';
import 'package:wajhatuk/constants.dart';

class AddCity extends StatefulWidget {
  final String userId;
  AddCity({required this.userId});
  @override
  _AddCityState createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> with SingleTickerProviderStateMixin {
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
        backgroundColor: lastColor, // Match color theme from your design

        title: Text('Cities Manager', style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mainColor),
          textAlign: TextAlign.center,),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Cities').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('..Downloading'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No cities found'));
          }

          return GridView.count(
            crossAxisCount: 4,
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return InkWell(
                  child: Expanded(
                    child: Card(
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              data['city_name'],
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: lastColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    color: lastColor,
                                    size: 12.0,
                                  ),
                                  onTap: () async {
                                    bool result = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          titleTextStyle: kTitleTextStyle,
                                          contentTextStyle: kTitleTextStyle,
                                          backgroundColor: mainColor,
                                          title: Text(
                                            'Sure',
                                            style: kTitleTextStyle,
                                          ),
                                          content: Text(
                                            'Are You Sure To Delete It ?',
                                            style: kTitleTextStyle,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop(
                                                        false); // dismiss dialog and return false
                                              },
                                              child: Text(
                                                'No',
                                                style: kTitleTextStyle,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('Cities')
                                                    .doc(document.id)
                                                    .delete()
                                                    .then((_) => print(
                                                        data['city_name'] +
                                                            ' deleted'));

                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop(
                                                        true); // dismiss dialog and return true
                                              },
                                              child: Text(
                                                'Yes',
                                                style: kTitleTextStyle,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 12.0,
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.edit,
                                    color: lastColor,
                                    size: 12.0,
                                  ),
                                  onTap: () {
                                    _showEditCityDialog(context, document);
                                    // Edit functionality here
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminPage(
                            cityId: document.id, name: data['city_name'],userId:widget.userId),
                      ),
                    );
                  });
            }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddCityDialog(context);
        },
      ),
    );
  }
}

void _showAddCityDialog(BuildContext context) {
  TextEditingController _cityNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cityNameController,
              decoration: InputDecoration(labelText: 'City Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addCityToFirestore(_cityNameController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

Future<void> _addCityToFirestore(String cityName) async {
  // Automatically adding the current timestamp for creation date
  await FirebaseFirestore.instance.collection('Cities').add({
    'city_name': cityName,
    'created_at': Timestamp.now(), // Auto-created current timestamp
  }).then((value) {
    print("City Added");
  }).catchError((error) {
    print("Failed to add city: $error");
  });
}

void _showEditCityDialog(BuildContext context, DocumentSnapshot document) {
  TextEditingController _cityNameController =
      TextEditingController(text: document['city_name']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cityNameController,
              decoration: InputDecoration(labelText: 'City Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_cityNameController.text.isNotEmpty) {
                _editCityInFirestore(document.id, _cityNameController.text);
                Navigator.of(context).pop();
              } else {
                print("City name cannot be empty");
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> _editCityInFirestore(String docId, String cityName) async {
  await FirebaseFirestore.instance.collection('Cities').doc(docId).update({
    'city_name': cityName,
  }).then((value) {
    print("City Updated");
  }).catchError((error) {
    print("Failed to update city: $error");
  });
}
