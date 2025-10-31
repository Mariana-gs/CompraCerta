// lib/widgets/cart_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartItemCard extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Function(double) onPriceChanged;

  const CartItemCard({
    Key? key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.onDecrement,
    required this.onIncrement,
    required this.onPriceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceController = TextEditingController(text: price.toStringAsFixed(2));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            _buildQuantityControl(),
            const SizedBox(width: 10),
            _buildPriceInput(context, priceController),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement, iconSize: 20),
          Text(quantity.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add), onPressed: onIncrement, iconSize: 20),
        ],
      ),
    );
  }

  Widget _buildPriceInput(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: const InputDecoration(
          prefixText: 'R\$ ',
          border: InputBorder.none,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        onSubmitted: (value) {
          final newPrice = double.tryParse(value) ?? 0.0;
          onPriceChanged(newPrice);
        },
      ),
    );
  }
}