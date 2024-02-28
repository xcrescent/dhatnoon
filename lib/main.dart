import 'package:dhatnoon/app/app.dart';
import 'package:dhatnoon/bootstrap.dart';
import 'package:dhatnoon/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// This entry point should be used for production only
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///You can override your environment variable in bootstrap method here for providers
  bootstrap(() => const App());
}
