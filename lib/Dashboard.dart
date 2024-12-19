import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String currentUserId;
  List<String> imageUrls = [];
  File? profileImage;

  String turfName = '';
  String turfDistrict = '';
  String turfRate = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
          currentUserId = userData.id;
          turfName = userData['TurfName'] ?? '';
          turfDistrict = userData['TurfDistrict'] ?? '';
          turfRate = userData['TurfRate'] ?? '';
          imageUrls = List<String>.from(userData['TurfImages'] ?? []);

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

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: 380,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 4 / 3,
                          viewportFraction: 1.0,
                        ),
                        items: imageUrls.map<Widget>((imageUrl) {
                          return Container(
                            width: double.infinity,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Turf Name: $turfName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 18),
                        SizedBox(width: 5),
                        Text(
                          'Turf District: $turfDistrict',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Available Sports:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (valueCricket) _buildSportTile({'icon': Icons.sports_cricket, 'name': 'Cricket'}),
                          if (valueFootball) _buildSportTile({'icon': Icons.sports_soccer, 'name': 'Football'}),
                          if (valueBasketball) _buildSportTile({'icon': Icons.sports_basketball, 'name': 'Basketball'}),
                          if (valueBadminton) _buildSportTile({'icon': Icons.sports_handball, 'name': 'Badminton'}),
                          if (valueVolleyball) _buildSportTile({'icon': Icons.sports_volleyball, 'name': 'Volleyball'}),
                          if (valueTennis) _buildSportTile({'icon': Icons.sports_tennis, 'name': 'Tennis'}),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Facilities:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (valueWifi) _buildFacilityTile({'icon': Icons.wifi, 'name': 'Wifi'}),
                          if (valueParking) _buildFacilityTile({'icon': Icons.local_parking, 'name': 'Parking'}),
                          if (valueFirstAid) _buildFacilityTile({'icon': Icons.local_hospital, 'name': 'First Aid'}),
                          if (valueRestroom) _buildFacilityTile({'icon': Icons.room_preferences, 'name': 'Restroom'}),
                          if (valueCCTV) _buildFacilityTile({'icon': Icons.photo_camera, 'name': 'CCTV'}),
                          if (valueCharging) _buildFacilityTile({'icon': Icons.charging_station, 'name': 'Charging'}),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Rate per Hour: ₹$turfRate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportTile(Map<String, dynamic> sport) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Icon(sport['icon'], size: 28, color: Colors.green.shade700),
          SizedBox(height: 6),
          Text(sport['name'], style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFacilityTile(Map<String, dynamic> facility) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Icon(facility['icon'], size: 28, color: Colors.blueAccent),
          SizedBox(height: 6),
          Text(facility['name'], style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
