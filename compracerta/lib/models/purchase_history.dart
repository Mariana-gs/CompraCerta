// lib/models/purchase_history.dart
import 'package:compracerta/models/shopping_list_item.dart';

class PurchaseHistory {
  final String id; // ID único para cada compra
  final String supermarketName;
  final List<ShoppingListItem> items;
  final double total;
  final double budget;
  final DateTime date;

  PurchaseHistory({
    required this.id,
    required this.supermarketName,
    required this.items,
    required this.total,
    required this.budget,
    required this.date,
  });

  // Métodos para conversão JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'supermarketName': supermarketName,
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'budget': budget,
        'date': date.toIso8601String(),
      };

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) => PurchaseHistory(
        id: json['id'],
        supermarketName: json['supermarketName'],
        items: (json['items'] as List)
            .map((itemJson) => ShoppingListItem.fromJson(itemJson))
            .toList(),
        total: (json['total'] as num).toDouble(),
        budget: (json['budget'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}