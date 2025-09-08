import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import '../controllers/team_controller.dart';
import 'team_history_edit_page.dart';

class TeamHistoryPage extends StatelessWidget {
  const TeamHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCtrl = Get.find<HistoryController>();
    final teamCtrl = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team History'),
        actions: [
          IconButton(
            tooltip: 'Clear All',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              if (historyCtrl.history.isEmpty) return;
              final ok = await _confirm(context, 'Delete all history?');
              if (ok) historyCtrl.clearAll();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: teamCtrl.team.isEmpty
            ? null
            : historyCtrl.addFromCurrentTeam,
        icon: const Icon(Icons.save),
        label: const Text('Save Current Team'),
      ),
      body: Obx(() {
        final items = historyCtrl.history;
        if (items.isEmpty) {
          return const Center(
            child: Text('No history yet. Build a team and save it here.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final rec = items[i];
            final date = rec.createdAt;
            final dateText =
                '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                title: Text(rec.name),
                subtitle: Text('$dateText • ${rec.members.length} members'),
                onTap: () {
                  Get.to(() => TeamHistoryEditPage(recordId: rec.id));
                },
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await _confirm(context, 'Delete this record?');
                    if (ok) historyCtrl.deleteById(rec.id);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('OK')),
        ],
      ),
    );
    return result ?? false;
  }
}
