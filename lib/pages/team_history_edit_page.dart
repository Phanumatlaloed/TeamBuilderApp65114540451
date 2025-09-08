import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';

class TeamHistoryEditPage extends StatefulWidget {
  const TeamHistoryEditPage({super.key, required this.recordId});
  final String recordId;

  @override
  State<TeamHistoryEditPage> createState() => _TeamHistoryEditPageState();
}

class _TeamHistoryEditPageState extends State<TeamHistoryEditPage> {
  late final HistoryController historyCtrl;
  late final TeamController teamCtrl;
  late final TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    historyCtrl = Get.find<HistoryController>();
    teamCtrl = Get.find<TeamController>();
    nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------
  Future<bool> _confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _saveName(String recordId) {
    historyCtrl.rename(recordId, nameCtrl.text);
    Get.snackbar('Saved', 'Team name updated',
        snackPosition: SnackPosition.BOTTOM);
  }

  void _replaceMembers(String recordId) {
    historyCtrl.replaceMembersWithCurrentTeam(recordId);
    Get.snackbar('Replaced', 'Members replaced with current team',
        snackPosition: SnackPosition.BOTTOM);
  }

  // แปลง Map ที่เก็บในประวัติ -> Pokemon
  Pokemon _mapToPokemon(Map<String, dynamic> m) {
    // id: อาจมาเป็น int หรือ string "#025"
    final dynamic rawId = m['id'];
    int id;
    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      final cleaned = rawId.replaceAll('#', '');
      id = int.tryParse(cleaned) ?? 0;
    } else {
      id = 0;
    }

    final String name = (m['name'] ?? 'Unknown').toString();
    final String imageUrl = (m['imageUrl'] ?? '').toString();

    return Pokemon(id: id, name: name, imageUrl: imageUrl);
  }

  void _loadToCurrentTeam(String recordId) {
    final idx = historyCtrl.history.indexWhere((e) => e.id == recordId);
    if (idx == -1) return;
    final rec = historyCtrl.history[idx];

    // อัปเดตชื่อทีม
    teamCtrl.renameTeam(rec.name);

    // ล้างและเติมใหม่ด้วย Pokemon แท้
    teamCtrl.team.clear();
    final pokes = rec.members
        .map((m) => _mapToPokemon(Map<String, dynamic>.from(m)))
        .toList();
    teamCtrl.team.addAll(pokes);

    Get.snackbar('Loaded', 'Loaded to current team',
        snackPosition: SnackPosition.BOTTOM);
  }

  void _removeMemberAt(String recordId, int index) async {
    final idx = historyCtrl.history.indexWhere((e) => e.id == recordId);
    if (idx == -1) return;
    final rec = historyCtrl.history[idx];
    if (index < 0 || index >= rec.members.length) return;

    rec.members.removeAt(index);
    historyCtrl.history.refresh();
    // ใช้ rename() เพื่อ trigger _save ภายใน controller
    historyCtrl.rename(recordId, rec.name);

    Get.snackbar('Removed', 'Member removed',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Saved Team'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await _confirm(context, 'Delete this record?');
              if (ok) {
                historyCtrl.deleteById(widget.recordId);
                Get.back();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final idx =
            historyCtrl.history.indexWhere((e) => e.id == widget.recordId);
        if (idx == -1) {
          return const Center(child: Text('Record not found.'));
        }
        final rec = historyCtrl.history[idx];

        // อัปเดต TextField เฉพาะเมื่อค่าเปลี่ยนจริง ป้องกันเคอร์เซอร์เด้ง
        if (nameCtrl.text != rec.name) {
          nameCtrl.text = rec.name;
          nameCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: nameCtrl.text.length),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ชื่อทีม
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _saveName(widget.recordId),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _saveName(widget.recordId),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Name'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _replaceMembers(widget.recordId),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Use Current Members'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text('Members (${rec.members.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  itemCount: rec.members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final m = rec.members[i];
                    final name = (m['name'] ?? 'Unknown').toString();
                    final id = m['id'];
                    final idText = (id == null) ? '#—' : '#$id';

                    return Card(
                      key: ValueKey('rec-${rec.id}-member-$i-${m['id']}-${m['name']}'),
                      child: ListTile(
                        leading: const Icon(Icons.catching_pokemon),
                        title: Text(name),
                        subtitle: Text(idText),
                        trailing: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeMemberAt(widget.recordId, i),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // โหลดบันทึกนี้กลับเป็นทีมปัจจุบัน
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _loadToCurrentTeam(widget.recordId),
                  icon: const Icon(Icons.download),
                  label: const Text('Load to Current Team'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
