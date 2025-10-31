// lib/models/shopping_list_item.dart

class ShoppingListItem {
  String name;
  bool isChecked;
  int quantity;
  double price;

  ShoppingListItem({
    required this.name,
    this.isChecked = false,
    this.quantity = 1,
    this.price = 0.0, // Preço pode ser definido no carrinho
  });

  // Converte o objeto para um mapa JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'isChecked': isChecked,
        'quantity': quantity,
        'price': price,
      };

  // Cria um objeto a partir de um mapa JSON
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem(
        name: json['name'],
        isChecked: json['isChecked'] ?? false,
        quantity: json['quantity'] ?? 1,
        // Garante que o preço seja lido como double
        price: (json['price'] ?? 0.0).toDouble(),
      );
}