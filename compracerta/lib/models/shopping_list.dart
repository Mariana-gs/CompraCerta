// lib/models/shopping_list.dart
import 'package:compracerta/models/shopping_list_item.dart';

class ShoppingList {
  String name;
  List<ShoppingListItem> items;

  ShoppingList({required this.name, required this.items});

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items.map((item) => item.toJson()).toList(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        name: json['name'],
        items: (json['items'] as List)
            .map((itemJson) => ShoppingListItem.fromJson(itemJson))
            .toList(),
      );
}