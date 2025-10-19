// lib/widgets/shopping_list_item_widget.dart
import 'package:flutter/material.dart';

class ShoppingListItemWidget extends StatelessWidget {
  final String itemName;
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;

  const ShoppingListItemWidget({
    Key? key,
    required this.itemName,
    required this.onDelete,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Fundo cinza claro do item
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              itemName,
              style: const TextStyle(
                fontSize: 16,
                // A fonte DM Sans será aplicada pelo tema global
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(icon: Icons.delete_outline, onTap: onDelete),
          const SizedBox(width: 8),
          _buildActionButton(icon: Icons.shopping_cart_outlined, onTap: onAddToCart),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
              )
            ]),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}