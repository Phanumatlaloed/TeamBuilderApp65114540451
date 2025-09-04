import 'package:get/get.dart';
import '../models/pokemon.dart';

class ApiService extends GetConnect {
  Future<List<Pokemon>> fetchPokemons({int limit = 151}) async {
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=$limit';
    final response = await get(url);

    if (response.statusCode == 200 && response.body != null) {
      final results = (response.body['results'] as List).cast<Map<String, dynamic>>();
      return results.map((m) {
        final name = m['name'] as String;
        final detailUrl = m['url'] as String; // .../pokemon/25/
        final id = _extractId(detailUrl);
        final img = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
        return Pokemon(id: id, name: _cap(name), imageUrl: img);
      }).toList();
    }

    Get.snackbar('Network Error', 'Failed to fetch Pokémon (${response.statusCode}).');
    return [];
  }

  int _extractId(String url) {
    final parts = url.split('/').where((s) => s.isNotEmpty).toList();
    final idStr = parts[parts.length - 1]; // ตัวเลขท้าย url
    return int.tryParse(idStr) ?? 0;
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
