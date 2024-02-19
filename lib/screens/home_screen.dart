import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _fetchAndStoreLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      FirebaseFirestore.instance.collection('locations').add({
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      });
      // Inform the user of success
    } catch (e) {
      // Handle the location fetch error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Fetch App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _fetchAndStoreLocation,
          child: const Text('Fetch Location'),
        ),
      ),
    );
  }
}
