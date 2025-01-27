import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:nada_async_app/Controllers/NadaLoginController.dart';
import 'package:nada_async_app/Views/NadaHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure surface rendering
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize the controller
  Get.put(NadaLoginController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.android,
        // Add this to help with rendering
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NadaHomePage(),
    );
  }
}
