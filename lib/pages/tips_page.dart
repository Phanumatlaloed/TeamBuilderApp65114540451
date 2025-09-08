import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = <String>[
      'เริ่มจากคาแรคเตอร์หลัก 1 ตัว แล้วเสริมบทบาทที่ขาด',
      'กระจายบทบาท (Attacker / Defender / Support) ให้สมดุล',
      'เลี่ยงการใช้ตัวซ้ำบทบาทเกินไป เพื่อความยืดหยุ่น',
      'ทดสอบทีมด้วยปุ่ม Preview แล้วสลับสมาชิกถ้าจุดอ่อนชัด',
      'อย่าลืมตั้งชื่อทีมให้สื่อความหมาย ง่ายต่อการจำ',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tips & Guides')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(tips[i]),
        ),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: tips.length,
      ),
    );
  }
}
