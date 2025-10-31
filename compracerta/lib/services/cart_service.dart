// lib/services/cart_service.dart
import 'dart:convert';
import 'package:compracerta/models/shopping_list_item.dart'; // ATUALIZE O IMPORT
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const _cartKey = 'shopping_cart_items';
  static const _budgetKey = 'shopping_cart_budget'; // Chave para o orçamento

  // Salva os itens do carrinho no dispositivo
  Future<void> saveCart(List<ShoppingListItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_cartKey, itemsJson);
  }

  // Carrega os itens do carrinho do dispositivo
  Future<List<ShoppingListItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsJson = prefs.getStringList(_cartKey) ?? [];
    return itemsJson.map((itemJson) => ShoppingListItem.fromJson(jsonDecode(itemJson))).toList();
  }

  // Adiciona um item ao carrinho
  Future<void> addItemToCart(ShoppingListItem item) async {
    final cartItems = await getCart();
    // Opcional: verificar se o item já existe e apenas incrementar a quantidade
    cartItems.add(item);
    await saveCart(cartItems);
  }

  // Remove um item do carrinho
  Future<void> removeItemFromCart(int index) async {
    final cartItems = await getCart();
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      await saveCart(cartItems);
    }
  }

  // Limpa todos os itens do carrinho
  Future<void> clearCart() async {
    await saveCart([]);
  }

  // --- NOVOS MÉTODOS PARA ORÇAMENTO ---

  // Salva o valor do orçamento
  Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, budget);
  }

  // Carrega o valor do orçamento
  Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 0.0; // Retorna 0 se não houver orçamento salvo
  }
}