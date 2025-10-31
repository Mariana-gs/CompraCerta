// lib/widgets/comparison_product_result_card.dart
import 'package:flutter/material.dart';

class ComparisonProductResultCard extends StatelessWidget {
  final String title;
  final String details;
  final bool isWinner;
  final VoidCallback onAddToCart; // <- Nova propriedade

  const ComparisonProductResultCard({
    Key? key,
    required this.title,
    required this.details,
    required this.isWinner,
    required this.onAddToCart, // <- Adicione ao construtor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isWinner ? 5 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isWinner ? Colors.green.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isWinner ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                // --- Ícone de Adicionar ao Carrinho ---
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.grey),
                  onPressed: onAddToCart,
                  tooltip: 'Adicionar ao carrinho',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (isWinner) ...[
              const SizedBox(height: 8),
              const Text(
                'Este é o mais vantajoso!',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}