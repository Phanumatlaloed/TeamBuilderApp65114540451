import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';

class TeamPreviewPage extends StatelessWidget {
  TeamPreviewPage({super.key});

  final TeamController teamCtrl = Get.find<TeamController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Preview')),
      body: Obx(() {
        final team = teamCtrl.team;
        if (team.isEmpty) {
          return const Center(child: Text('No Pokémon selected.'));
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: team.length,
            itemBuilder: (context, i) {
              final p = team[i];
              return Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(p.imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text('#${p.id}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Reset Team'),
            onPressed: teamCtrl.resetTeam,
          ),
        ),
      ),
    );
  }
}
