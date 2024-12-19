import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfadmin/Login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController Name = TextEditingController();
  TextEditingController TurfName = TextEditingController();
  TextEditingController TurfDistrict = TextEditingController();
  TextEditingController TurfRate = TextEditingController();
  bool valueCricket = false;
  bool valueFootball = false;
  bool valueBasketball = false;
  bool valueBadminton = false;
  bool valueVolleyball = false;
  bool valueTennis = false;
  bool valueWifi = false;
  bool valueParking = false;
  bool valueFirstAid = false;
  bool valueRestroom = false;
  bool valueCCTV = false;
  bool valueCharging = false;

  final CollectionReference admin = FirebaseFirestore.instance.collection("Admin");
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late String currentUserId;
  List<String> imageUrls = [];
  String? profileImage;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future fetchDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs[0];
        setState(() {
          currentUserId = userData.id;
          Name.text = userData['Name'];
          TurfName.text = userData['TurfName'];
          TurfDistrict.text = userData['TurfDistrict'];
          TurfRate.text = userData['TurfRate'];
          imageUrls = List<String>.from(userData['TurfImages'] ?? []);
          profileImage = userData['ProfilePicture'];
          var sports = userData['Sports'];
          valueCricket = sports['Cricket'] ?? false;
          valueFootball = sports['Football'] ?? false;
          valueBasketball = sports['Basketball'] ?? false;
          valueBadminton = sports['Badminton'] ?? false;
          valueVolleyball = sports['Volleyball'] ?? false;
          valueTennis = sports['Tennis'] ?? false;

          var facilities = userData['Facilities'];
          valueWifi = facilities['Wifi'] ?? false;
          valueParking = facilities['Parking'] ?? false;
          valueFirstAid = facilities['First Aid'] ?? false;
          valueRestroom = facilities['Restroom'] ?? false;
          valueCCTV = facilities['CCTV'] ?? false;
          valueCharging = facilities['Charging'] ?? false;
        });
      }
    } catch (e) {
      print('Error:$e');
    }
  }

  Future<void> pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        String fileName = pickedFile.name;
        Reference storageRef = storage.ref().child("Turf_Images/$currentUserId/$fileName");
        await storageRef.putFile(File(pickedFile.path));
        String downloadUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('Admin')
            .doc(currentUserId)
            .update({
          'TurfImages': FieldValue.arrayUnion([downloadUrl]),
        }).then((_) {
          setState(() {
            imageUrls.add(downloadUrl);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Image added successfully'),
            backgroundColor: Colors.green,
          ));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error uploading image: $error'),
            backgroundColor: Colors.red,
          ));
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference storageRef = storage.refFromURL(imageUrl);
      await storageRef.delete();

      FirebaseFirestore.instance.collection('Admin').doc(currentUserId).update({
        'TurfImages': FieldValue.arrayRemove([imageUrl]),
      }).then((_) {
        setState(() {
          imageUrls.remove(imageUrl);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image deleted successfully'),
          backgroundColor: Colors.green,
        ));
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      });
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> changeProfilePicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        String fileName = pickedFile.name;
        Reference storageRef = storage.ref().child("Profile_Pictures/$currentUserId/$fileName");
        await storageRef.putFile(File(pickedFile.path));
        String downloadUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('Admin')
            .doc(currentUserId)
            .update({'ProfilePicture': downloadUrl}).then((_) {
          setState(() {
            profileImage = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error updating profile picture: $error'),
            backgroundColor: Colors.red,
          ));
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('Admin').doc(currentUserId).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account deleted successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
  Future signout() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
      content: Text(
        'Signout successfully',
        style: TextStyle(color: Colors.black),
      ),
      action: SnackBarAction(
          label: 'Cancel', textColor: Colors.black, onPressed: () {}),
    ));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();
    preferences.setBool('islogged',false);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: profileImage == null
                    ? AssetImage('lib/Images/Default.png')
                    : NetworkImage(profileImage!) as ImageProvider,
                radius: 60,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: changeProfilePicture,
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Admin')
                  .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No profile data available"));
                }

                var userData = snapshot.data!.docs[0];

                return ExpansionTile(
                  title: Text(
                    'My Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${userData['Name']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Text('Turf Name: ${userData['TurfName']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Text('Turf District: ${userData['TurfDistrict']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Text('Turf Rate: ${userData['TurfRate']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Update Data'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: Name,
                                            decoration: InputDecoration(
                                              labelText: 'Name',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: TurfName,
                                            decoration: InputDecoration(
                                              labelText: 'Turf Name',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: TurfDistrict,
                                            decoration: InputDecoration(
                                              labelText: 'Turf District',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: TurfRate,
                                            decoration: InputDecoration(
                                              labelText: 'Turf Rate',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('Admin')
                                                .doc(userData.id)
                                                .update({
                                              'Name': Name.text,
                                              'TurfName': TurfName.text,
                                              'TurfDistrict': TurfDistrict.text,
                                              'TurfRate': TurfRate.text,
                                            }).then((_) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Profile updated successfully!'),
                                                backgroundColor: Colors.green,
                                              ));
                                            }).catchError((e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ));
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('Update'),
                                        ),
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text(
                'Turf Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: pickAndUploadImage,
                      child: Text('Add Turf Images'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => deleteImage(imageUrls[index]),
                  child: GridTile(
                    child: Image.network(imageUrls[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text(
                'Available Sports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSportCheckbox('Cricket', valueCricket, (newValue) {
                        setState(() {
                          valueCricket = newValue!;
                        });
                      }),
                      _buildSportCheckbox('Football', valueFootball, (newValue) {
                        setState(() {
                          valueFootball = newValue!;
                        });
                      }),
                      _buildSportCheckbox('Basketball', valueBasketball, (newValue) {
                        setState(() {
                          valueBasketball = newValue!;
                        });
                      }),
                      _buildSportCheckbox('Badminton', valueBadminton, (newValue) {
                        setState(() {
                          valueBadminton = newValue!;
                        });
                      }),
                      _buildSportCheckbox('Volleyball', valueVolleyball, (newValue) {
                        setState(() {
                          valueVolleyball = newValue!;
                        });
                      }),
                      _buildSportCheckbox('Tennis', valueTennis, (newValue) {
                        setState(() {
                          valueTennis = newValue!;
                        });
                      }),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            _updateSportsFacilities();
                          },
                          child: Text('Update Sports'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text(
                'Available Facilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFacilityCheckbox('Wifi', valueWifi, (newValue) {
                        setState(() {
                          valueWifi = newValue!;
                        });
                      }),
                      _buildFacilityCheckbox('Parking', valueParking, (newValue) {
                        setState(() {
                          valueParking = newValue!;
                        });
                      }),
                      _buildFacilityCheckbox('First Aid', valueFirstAid, (newValue) {
                        setState(() {
                          valueFirstAid = newValue!;
                        });
                      }),
                      _buildFacilityCheckbox('Restroom', valueRestroom, (newValue) {
                        setState(() {
                          valueRestroom = newValue!;
                        });
                      }),
                      _buildFacilityCheckbox('CCTV', valueCCTV, (newValue) {
                        setState(() {
                          valueCCTV = newValue!;
                        });
                      }),
                      _buildFacilityCheckbox('Charging', valueCharging, (newValue) {
                        setState(() {
                          valueCharging = newValue!;
                        });
                      }),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            _updateSportsFacilities();
                          },
                          child: Text('Update Facilities'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text(
                'Account Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        title: Text(
                          'Contact Us',
                          style: TextStyle(fontSize: 16),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone Number: +917025890421'),
                                Text('Email Address: ronysunil@gmail.com'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            deleteAccount();
                          },
                          child: Text('Delete Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  signout();
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CheckboxListTile _buildSportCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
    );
  }

  CheckboxListTile _buildFacilityCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateSportsFacilities() {
    FirebaseFirestore.instance.collection('Admin').doc(currentUserId).update({
      'Sports': {
        'Cricket': valueCricket,
        'Football': valueFootball,
        'Basketball': valueBasketball,
        'Badminton': valueBadminton,
        'Volleyball': valueVolleyball,
        'Tennis': valueTennis,
      },
      'Facilities': {
        'Wifi': valueWifi,
        'Parking': valueParking,
        'First Aid': valueFirstAid,
        'Restroom': valueRestroom,
        'CCTV': valueCCTV,
        'Charging': valueCharging,
      },
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sports and Facilities updated successfully!'),
        backgroundColor: Colors.green,
      ));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    });
  }
}
