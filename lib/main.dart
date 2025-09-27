import 'package:admin_coffee/controllers/dashbord_controller.dart';
import 'package:admin_coffee/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // ✅ مهم جدًا قبل استخدام التخزين

  Get.put(DashboardController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(), // ممكن استبدالها بـ SplashPage لو أردت
    );
  }
}
