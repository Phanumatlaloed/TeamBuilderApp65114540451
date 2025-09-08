import 'package:flutter/foundation.dart';

/// บันทึก 1 รายการในประวัติทีม
class TeamRecord {
  final String id;            // unique id
  String name;                // ชื่อทีม ณ ตอนบันทึก
  final DateTime createdAt;   // เวลาเมื่อบันทึก
  List<Map<String, dynamic>> members; // สมาชิก ณ ตอนบันทึก (เก็บแบบ map เพื่อไม่ผูกกับโมเดล)

  TeamRecord({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.members,
  });

  /// สร้างจากทีมปัจจุบัน (list ของ object ที่มี field name,id)
  static TeamRecord fromCurrent({
    required String id,
    required String name,
    required List<dynamic> team, // รองรับ dynamic model
  }) {
    final members = team.map<Map<String, dynamic>>((e) {
      final m = <String, dynamic>{};
      try {
        // รองรับทั้ง model มีฟิลด์ name,id หรือ map
        final dynamicName = (e is Map) ? e['name'] : (e as dynamic).name;
        final dynamicId   = (e is Map) ? e['id']   : (e as dynamic).id;
        m['name'] = dynamicName?.toString();
        m['id']   = dynamicId;
      } catch (_) {
        // ถ้าอ่านไม่ได้ ให้เก็บทั้ง object เป็นข้อความ
        m['name'] = e.toString();
        m['id'] = null;
      }
      return m;
    }).toList();

    return TeamRecord(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      members: members,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'members': members,
  };

  factory TeamRecord.fromJson(Map<String, dynamic> json) {
    return TeamRecord(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      members: (json['members'] as List<dynamic>? ?? const [])
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  @override
  String toString() => 'TeamRecord($id, $name, ${members.length} members)';
}
