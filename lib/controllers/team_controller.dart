import 'package:get/get.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';

class TeamController extends GetxController {
  final ApiService api = Get.find<ApiService>();

  final RxString teamName = 'Pokémon Team Builder'.obs;
  final RxList<Pokemon> pokemons = <Pokemon>[].obs;
  final RxList<Pokemon> team = <Pokemon>[].obs;
  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;

  bool get isFull => team.length >= 3;

  @override
  void onInit() {
    super.onInit();
    loadPokemons(limit: 151);
  }

  Future<void> loadPokemons({int limit = 151}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final list = await api.fetchPokemons(limit: limit);
      pokemons.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  List<Pokemon> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return pokemons;
    return pokemons.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  void setQuery(String q) => query.value = q;

  bool selected(Pokemon p) => team.contains(p);

  void togglePokemon(Pokemon p) {
    if (selected(p)) {
      team.remove(p);
    } else {
      if (isFull) {
        Get.snackbar("Limit Reached", "You can only choose 3 Pokémon!");
        return;
      }
      team.add(p);
    }
  }

  void resetTeam() => team.clear();

  void renameTeam(String name) {
    final n = name.trim();
    if (n.isNotEmpty) teamName.value = n;
  }
}
