import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../widgets/pokemon_list.dart';
import 'team_preview_page.dart';
import 'team_stats_page.dart'; 
import 'tips_page.dart';       

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final TeamController teamCtrl = Get.find<TeamController>(); 
  final TextEditingController _nameController = TextEditingController();

  void _openRenameDialog(BuildContext context) {
    _nameController.text = teamCtrl.teamName.value;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Team'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter team name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              teamCtrl.renameTeam(_nameController.text.trim());
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(teamCtrl.teamName.value)),
        actions: [
          IconButton(
            tooltip: 'Edit Team Name',
            icon: const Icon(Icons.edit),
            onPressed: () => _openRenameDialog(context),
          ),
          IconButton(
            tooltip: 'Reset Team',
            icon: const Icon(Icons.refresh),
            onPressed: teamCtrl.resetTeam,
          ),
        ],
      ),
      body: Column(
        children: [
          // ปุ่ม Preview Team
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => TeamPreviewPage()),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview Team'),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const TeamStatsPage()),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Team Stats'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const TipsPage()),
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Tips & Guides'),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search Pokémon...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: teamCtrl.setQuery,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Team: ${teamCtrl.team.length}/3',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

        
          Expanded(child: PokemonList()),
        ],
      ),
    );
  }
}
