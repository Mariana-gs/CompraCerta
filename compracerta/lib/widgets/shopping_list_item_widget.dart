// lib/widgets/shopping_list_item_widget.dart
import 'package:flutter/material.dart';

class ShoppingListItemWidget extends StatelessWidget {
  final String itemName;
  final bool isInCart; // <- NOVA PROPRIEDADE
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;

  const ShoppingListItemWidget({
    Key? key,
    required this.itemName,
    required this.isInCart, // <- ADICIONE AO CONSTRUTOR
    required this.onDelete,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          itemName,
          // Muda o estilo do texto se o item estiver no carrinho
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isInCart ? TextDecoration.lineThrough : TextDecoration.none,
            color: isInCart ? Colors.grey : Colors.black,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Desabilita o botão e muda o ícone se já estiver no carrinho
            IconButton(
              icon: Icon(
                isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                color: isInCart ? Colors.green : Colors.black,
              ),
              onPressed: isInCart ? null : onAddToCart, // Desabilita o clique
              tooltip: isInCart ? 'Já está no carrinho' : 'Adicionar ao carrinho',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}