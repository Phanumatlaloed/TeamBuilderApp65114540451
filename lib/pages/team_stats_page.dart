import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/team_controller.dart';
import 'team_preview_page.dart';

class TeamStatsPage extends StatelessWidget {
  const TeamStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teamCtrl = Get.find<TeamController>();

    // --- helpers ---
    void sortByName() {
      final list = teamCtrl.team.toList();
      list.sort((a, b) => (a.name ?? '').toString().toLowerCase().compareTo(
            (b.name ?? '').toString().toLowerCase(),
          ));
      teamCtrl.team.assignAll(list);
    }

    void sortById() {
      final list = teamCtrl.team.toList();

      int parseId(dynamic x) {
        if (x == null) return 1 << 30;
        final s = x.toString().replaceAll('#', '');
        return int.tryParse(s) ?? (1 << 30);
      }

      list.sort((a, b) => parseId(a.id).compareTo(parseId(b.id)));
      teamCtrl.team.assignAll(list);
    }

    void clearTeam() {
      teamCtrl.resetTeam();
    }

    Future<void> copyTeamToClipboard() async {
      final items = teamCtrl.team
          .map((p) {
            final name = p.name?.toString() ?? 'Unknown';
            final id = p.id?.toString();
            return id != null ? '$name (#$id)' : name;
          })
          .toList()
          .join(', ');
      await Clipboard.setData(ClipboardData(text: items));
      Get.snackbar('Copied', 'Team copied to clipboard',
          snackPosition: SnackPosition.BOTTOM);
    }

    void onReorder(int oldIndex, int newIndex) {
      final list = teamCtrl.team;
      if (newIndex > oldIndex) newIndex -= 1;
      if (oldIndex < 0 || oldIndex >= list.length) return;
      if (newIndex < 0 || newIndex > list.length) return;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      // RxList จะอัปเดต UI ให้เอง
    }

    void removeAt(int index) {
      if (index >= 0 && index < teamCtrl.team.length) {
        final removed = teamCtrl.team.removeAt(index);
        Get.snackbar('Removed', '${removed.name ?? 'Pokémon'} removed',
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    const maxMembers = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          final team = teamCtrl.team;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Name: ${teamCtrl.teamName.value}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text('Members: ${team.length}/$maxMembers'),
              const SizedBox(height: 12),

              // toolbar
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: sortByName,
                    icon: const Icon(Icons.sort_by_alpha),
                    label: const Text('Sort A–Z'),
                  ),
                  OutlinedButton.icon(
                    onPressed: sortById,
                    icon: const Icon(Icons.format_list_numbered),
                    label: const Text('Sort by ID'),
                  ),
                  OutlinedButton.icon(
                    onPressed: team.isEmpty ? null : copyTeamToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Team'),
                  ),
                  OutlinedButton.icon(
                    onPressed: team.isEmpty ? null : clearTeam,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Team'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // list / empty
              Expanded(
                child: team.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(height: 8),
                            const Text('No Pokémon selected yet.'),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => Get.to(() => TeamPreviewPage()),
                              icon: const Icon(Icons.visibility),
                              label: const Text('Open Preview'),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: team.length,
                        onReorder: onReorder,
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final p = team[index];
                          final name = p.name?.toString() ?? 'Unknown';
                          final idText =
                              p.id != null ? '#${p.id}' : '#—';

                          return ListTile(
                            key: ValueKey('${p.id ?? name}-$index'),
                            leading: const Icon(Icons.catching_pokemon),
                            title: Text(name),
                            subtitle: Text(idText),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.close),
                                  onPressed: () => removeAt(index),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ],
                            ),
                            onTap: () => Get.to(() => TeamPreviewPage()),
                          );
                        },
                      ),
              ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => TeamPreviewPage()),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Open Preview'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
