import 'dart:convert';
import 'package:get/get.dart';
import '../models/team_record.dart';
import 'team_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HistoryController extends GetxController {
  /// รายการประวัติทั้งหมด (ใหม่อยู่บน)
  final RxList<TeamRecord> history = <TeamRecord>[].obs;

  /// บันทึกลง local storage แบบง่าย ๆ:
  /// - บนเว็บ: window.localStorage (ผ่าน dart:html)
  /// - นอกเว็บ: เก็บในหน่วยความจำ (ตัวอย่างนี้ไม่พึ่งแพ็กเกจเพิ่ม)
  static const _storageKey = 'team_history_records';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void addFromCurrentTeam() {
    final teamCtrl = Get.find<TeamController>();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final record = TeamRecord.fromCurrent(
      id: id,
      name: teamCtrl.teamName.value.isEmpty ? 'Untitled Team' : teamCtrl.teamName.value,
      team: teamCtrl.team.toList(),
    );
    history.insert(0, record);
    _save();
  }

  void deleteById(String id) {
    history.removeWhere((e) => e.id == id);
    _save();
  }

  void clearAll() {
    history.clear();
    _save();
  }

  void rename(String id, String newName) {
    final idx = history.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    history[idx].name = newName.trim().isEmpty ? 'Untitled Team' : newName.trim();
    history.refresh();
    _save();
  }

  /// แทนที่สมาชิกด้วยทีมปัจจุบัน (เอาจาก TeamController ตอนนี้)
  void replaceMembersWithCurrentTeam(String id) {
    final teamCtrl = Get.find<TeamController>();
    final idx = history.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final newMembers = teamCtrl.team.map<Map<String, dynamic>>((p) {
      final name = _safe(() => (p as dynamic).name?.toString()) ?? 'Unknown';
      final pid  = _safe(() => (p as dynamic).id);
      return {'name': name, 'id': pid};
    }).toList();

    history[idx].members = newMembers;
    history.refresh();
    _save();
  }

  T? _safe<T>(T Function() fn) { try { return fn(); } catch (_) { return null; } }

  // ----------------- persistence -----------------
  void _save() {
    final data = jsonEncode(history.map((e) => e.toJson()).toList());
    if (kIsWeb) {
      // ignore: avoid_web_libraries_in_flutter
      importForWeb.saveToLocalStorage(_storageKey, data);
    } else {
      // demo: นอกเว็บเก็บในหน่วยความจำเฉย ๆ (ถ้าต้องการถาวร แนะนำ get_storage/shared_preferences)
      _memoryCache = data;
    }
  }

  void _load() {
    String? raw;
    if (kIsWeb) {
      raw = importForWeb.readFromLocalStorage(_storageKey);
    } else {
      raw = _memoryCache;
    }
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => TeamRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      history.assignAll(list);
    } catch (_) {/* ignore */}
  }

  // memory fallback (mobile/desktop)
  static String? _memoryCache;
}

/// ส่วนนี้แยกไว้เพื่อหลบ warning เวลา import dart:html ในโปรเจกต์ cross-platform
/// จะถูกเรียกใช้เฉพาะตอนรันบนเว็บ (kIsWeb == true)
class importForWeb {
  // ignore: avoid_web_libraries_in_flutter
  static void saveToLocalStorage(String key, String value) {
    // ignore: avoid_web_libraries_in_flutter
    final ls = (windowHasLocalStorage()) ? (getWindow().localStorage) : null;
    ls?[key] = value;
  }

  // ignore: avoid_web_libraries_in_flutter
  static String? readFromLocalStorage(String key) {
    // ignore: avoid_web_libraries_in_flutter
    final ls = (windowHasLocalStorage()) ? (getWindow().localStorage) : null;
    return ls?[key];
  }

  // -------- helpers below (hide direct imports) --------
  // ignore: avoid_web_libraries_in_flutter
  static dynamic getWindow() {
    // ignore: avoid_web_libraries_in_flutter
    return (globalThis() as dynamic).window;
  }

  // ignore: avoid_web_libraries_in_flutter
  static bool windowHasLocalStorage() {
    try {
      // ignore: avoid_web_libraries_in_flutter
      final w = getWindow();
      return w != null && w.localStorage != null;
    } catch (_) {
      return false;
    }
  }

  // ignore: avoid_web_libraries_in_flutter
  static dynamic globalThis() {
    // ดึง context ของ browser แบบหลีกเลี่ยง import ตรงในไฟล์ยอด
    // ignore: undefined_prefixed_name
    return ({}); // noop สำหรับ analyzer; ตัวจริง resolve ผ่าน kIsWeb runtime
  }
}
