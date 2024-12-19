import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageBooking extends StatefulWidget {
  @override
  _ManageBookingState createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {
  String adminTurfName = '';
  List<DocumentSnapshot> bookings = [];

  @override
  void initState() {
    super.initState();
    getAdminDetails();
  }

  Future<void> getAdminDetails() async {
    var adminSnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      setState(() {
        adminTurfName = adminSnapshot.docs.first['TurfName'];
      });
      fetchBookings();
    }
  }

  Future<void> fetchBookings() async {
    var bookingsSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('TurfName', isEqualTo: adminTurfName)
        .where('Status', isEqualTo: 'Pending')
        .get();

    setState(() {
      bookings = bookingsSnapshot.docs;
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance.collection('Bookings').doc(bookingId).update({
      'Status': status,
    });
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings'),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.blue,
              Colors.purple,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(20.0),
              child: bookings.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  var booking = bookings[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Turf Name: ${booking['TurfName']}'),
                          Text('Total Amount: ${booking['TotalAmount']}'),
                          Text('Start Date: ${booking['StartDate'].toDate()}'),
                          Text('Start Time: ${booking['StartTime']}'),
                          Text('Required Hours: ${booking['RequiredHours']}'),
                          Text('Payment: ${booking['Payment']}'),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => updateBookingStatus(booking.id, 'Approved'),
                                child: Text('Approve'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                              ElevatedButton(
                                onPressed: () => updateBookingStatus(booking.id, 'Declined'),
                                child: Text('Decline'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
