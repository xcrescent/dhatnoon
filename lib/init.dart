import 'package:dhatnoon/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:platform_info/platform_info.dart';

///This function is used for setting up default orientation,
///display refresh rate, hide keyboard etc system services.
Future<void> init() async {
  await Firebase.initializeApp(
    name: 'Dhatnoon',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await platform.when(
    android: FlutterDisplayMode.setHighRefreshRate,
  );
  await SystemChannels.textInput.invokeMethod('TextInput.hide');
}
