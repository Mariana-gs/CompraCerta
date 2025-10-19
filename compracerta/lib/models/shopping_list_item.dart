// lib/models/shopping_list_item.dart
class ShoppingListItem {
  String name;
  bool isInCart;

  ShoppingListItem({required this.name, this.isInCart = false});
}