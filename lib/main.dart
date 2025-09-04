import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/team_controller.dart';
import 'pages/main_page.dart';
import 'services/api_service.dart';

void main() {
  // ลงทะเบียน dependency ที่นี่ที่เดียว
  Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
  Get.put(TeamController()); // ✅ ใส่ครั้งเดียวที่ main

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ✅ ต้องเป็น GetMaterialApp
      title: 'Pokémon Team Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}
