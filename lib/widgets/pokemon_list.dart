import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';

class PokemonList extends StatelessWidget {
  PokemonList({super.key});

  final TeamController teamCtrl = Get.find<TeamController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (teamCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final List<Pokemon> list = teamCtrl.filtered;
      if (list.isEmpty) {
        return const Center(child: Text('No Pokémon found.'));
      }

      return ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = list[index];

          // ✅ ครอบ “ทั้ง ListTile” ด้วย Obx เพื่อ rebuild ต่อรายการ
          return Obx(() {
            final isSelected = teamCtrl.selected(p);
            final canSelect = isSelected || !teamCtrl.isFull;

            return ListTile(
              leading: Image.network(
                p.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),
              title: Text(p.name),
              subtitle: Text('#${p.id}'),
              trailing: Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              onTap: canSelect ? () => teamCtrl.togglePokemon(p) : null,
            );
          });
        },
      );
    });
  }
}
