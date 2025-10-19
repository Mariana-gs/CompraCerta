// lib/models/shopping_list_item.dart
class ShoppingListItem {
  String name;
  bool isInCart;

  ShoppingListItem({required this.name, this.isInCart = false});

  // Converte um objeto ShoppingListItem em um Map (JSON)
  Map<String, dynamic> toJson() => {
        'name': name,
        'isInCart': isInCart,
      };

  // Cria um objeto ShoppingListItem a partir de um Map (JSON)
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem(
        name: json['name'],
        isInCart: json['isInCart'],
      );
}