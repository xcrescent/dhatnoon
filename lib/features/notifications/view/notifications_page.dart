import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage(
  deferredLoading: true,
)
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications Page'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('location_requests')
              .where('targetUid',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (!snapshot.hasData) return const LinearProgressIndicator();
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No requests found'),
              );
            }
            if (snapshot.hasError) return ErrorWidget('Error');

            // Display requests to the user in UI
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot request = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(request['requesterName']),
                  subtitle: Text(request['requesterEmail']),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Accept the request
                      FirebaseFirestore.instance
                          .collection('permission_requests')
                          .doc(request.id)
                          .update({'status': 'accepted'});
                    },
                    child: const Text('Accept'),
                  ),
                );
              },
            );
          },
        ));
  }
}
