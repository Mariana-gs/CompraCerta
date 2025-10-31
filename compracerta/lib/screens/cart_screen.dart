// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/services/cart_service.dart';
import 'package:compracerta/widgets/cart_item_card.dart'; // Importe o novo widget
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<ShoppingListItem> _cartItems = [];
  double _budget = 0.0;
  double _total = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    final items = await _cartService.getCart();
    final budget = await _cartService.getBudget();
    setState(() {
      _cartItems = items;
      _budget = budget;
      _calculateTotal();
      _isLoading = false;
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    setState(() { _total = total; });
  }

  void _updateItem(int index, ShoppingListItem item) {
    setState(() {
      _cartItems[index] = item;
    });
    _cartService.saveCart(_cartItems);
    _calculateTotal();
  }

  void _removeItem(int index) async {
    setState(() {
      _cartItems.removeAt(index);
    });
    await _cartService.saveCart(_cartItems);
    _calculateTotal();
  }

  Future<void> _showEditBudgetDialog() async {
    final TextEditingController budgetController = TextEditingController(text: _budget > 0 ? _budget.toStringAsFixed(2) : '');
    final newBudget = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Orçamento'),
        content: TextField(
          controller: budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: 'Ex: 400.00',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(budgetController.text.replaceAll(',', '.')) ?? 0.0;
              Navigator.pop(context, value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newBudget != null) {
      await _cartService.saveBudget(newBudget);
      setState(() { _budget = newBudget; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _cartItems.isEmpty
                        ? const Center(child: Text('Seu carrinho está vazio.'))
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return CartItemCard(
                                  name: item.name,
                                  quantity: item.quantity,
                                  price: item.price,
                                  onDecrement: () {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                      _updateItem(index, item);
                                    } else {
                                      _removeItem(index);
                                    }
                                  },
                                  onIncrement: () {
                                    item.quantity++;
                                    _updateItem(index, item);
                                  },
                                  onPriceChanged: (newPrice) {
                                    item.price = newPrice;
                                    _updateItem(index, item);
                                  },
                                );
                              },
                            ),
                        ),
                  ),
                  _buildFooter(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF82C8A0), // Verde do design
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  'CARRINHO',
                  style: GoogleFonts.bungee(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final progress = (_budget > 0 && _total > 0) ? (_total / _budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORÇAMENTO', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('R\$${_budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: progress > 0.85 ? Colors.red : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Botão Editar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEditBudgetDialog,
                ),
              ),
              const SizedBox(width: 8),
              // Botão Histórico (sem funcionalidade ainda)
              Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'TOTAL: R\$${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
          ),
        ],
      ),
    );
  }
}