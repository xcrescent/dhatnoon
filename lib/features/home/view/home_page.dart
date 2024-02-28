import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../login/model/app_user.dart';

@RoutePage(
  deferredLoading: true,
)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Future<void> _requestPermission() async {
  //   PermissionStatus status = await Permission.locationWhenInUse.request();

  //   if (status.isGranted) {
  //     // Permission is granted, proceed
  //   } else if (status.isDenied) {
  //     _showPermissionDeniedDialog();
  //   } else if (status.isPermanentlyDenied) {
  //     openAppSettings(); // Direct the user to app settings
  //   }
  // }

  // void _showPermissionDeniedDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text("Permission Denied"),
  //       content: Text(
  //           "This app needs location permission to function. Please enable it in app settings."),
  //       actions: [
  //         TextButton(
  //           child: Text("Cancel"),
  //           onPressed: () => Navigator.of(context).pop(),
  //         ),
  //         TextButton(
  //           child: Text("Settings"),
  //           onPressed: () => openAppSettings(),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _fetchAndStoreLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      // Open app settings to let the user manually allow permission
      Geolocator.openAppSettings();
      return;
    }
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
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch location')),
      );
    }
  }

  Stream<List<AppUser>> usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Fetch App'),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.router.pushNamed('/notifications')),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: usersStream(), // Reference the stream here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ListTile(
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage: user.photoUrl == ''
                              ? null
                              : NetworkImage(user.photoUrl),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Send a location request to the user
                        await FirebaseFirestore.instance
                            .collection('permission_requests')
                            .add({
                          'requesterUid': user.uid,
                          'requesterName': user.displayName,
                          'requesterEmail': user.email,
                          'targetUid': user.uid,
                          'status': 'pending',
                          'timestamp': Timestamp.now(),
                        });
                      },
                      child: const Text(
                        'Request Location',
                      ),
                    ),
                    // const SizedBox(
                    //   width: 4,
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Send a message to the user
                    //     FirebaseFirestore.instance
                    //         .collection('messages')
                    //         .add({
                    //       'senderUid': FirebaseAuth.instance.currentUser?.uid,
                    //       'senderName':
                    //           FirebaseAuth.instance.currentUser?.displayName,
                    //       'senderEmail':
                    //           FirebaseAuth.instance.currentUser?.email,
                    //       'receiverUid': user.uid,
                    //       'message': 'Hello, ${user.name}',
                    //       'timestamp': Timestamp.now(),
                    //     });
                    //   },
                    //   child: const Text(
                    //     'Send Message',
                    //   ),
                    // ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: Text('No users found'));
          }
        },
      ),
      // Center(
      //   child: ElevatedButton(
      //     onPressed: _fetchAndStoreLocation,
      //     child: const Text('Fetch Location'),
      //   ),
      // ),
    );
  }
}
