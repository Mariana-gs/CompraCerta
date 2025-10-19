// lib/services/shopping_list_service.dart
import 'dart:convert';
import 'package:compracerta/models/shopping_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListService {
  static const _listsKey = 'shopping_lists';
  static const _activeListKey = 'active_shopping_list_name';

  // Salva todas as listas no dispositivo
  Future<void> saveLists(List<ShoppingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listsJson = lists.map((list) => jsonEncode(list.toJson())).toList();
    await prefs.setStringList(_listsKey, listsJson);
  }

  // Carrega todas as listas do dispositivo
  Future<List<ShoppingList>> getLists() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listsJson = prefs.getStringList(_listsKey) ?? [];
    if (listsJson.isEmpty) {
      // Se não houver listas, cria uma padrão
      return [ShoppingList(name: 'Minha Primeira Lista', items: [])];
    }
    return listsJson.map((listJson) => ShoppingList.fromJson(jsonDecode(listJson))).toList();
  }

  // Define qual lista é a ativa
  Future<void> setActiveList(String listName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeListKey, listName);
  }

  // Obtém a lista que foi marcada como ativa
  Future<ShoppingList> getActiveList() async {
    final prefs = await SharedPreferences.getInstance();
    final allLists = await getLists();
    String? activeListName = prefs.getString(_activeListKey);

    if (activeListName == null) {
      // Se nenhuma lista ativa for encontrada, torna a primeira da lista a ativa
      await setActiveList(allLists.first.name);
      return allLists.first;
    }

    return allLists.firstWhere(
      (list) => list.name == activeListName,
      orElse: () {
        // Se a lista salva como ativa foi deletada, define a primeira como nova ativa
        setActiveList(allLists.first.name);
        return allLists.first;
      },
    );
  }
}