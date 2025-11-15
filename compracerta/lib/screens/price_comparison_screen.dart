// lib/screens/price_comparison_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:compracerta/models/shopping_list.dart';
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/services/price_comparison_service.dart';
import 'package:compracerta/services/shopping_list_service.dart';
import 'package:compracerta/services/cart_service.dart';
import 'package:compracerta/screens/shopping_list_screen.dart';
import 'package:compracerta/screens/cart_screen.dart';
import 'package:compracerta/widgets/custom_bottom_nav_bar.dart';

// --- Definição das Cores do Design ---
const kYellowColor = Color(0xFFFFD54F); // Amarelo vibrante
const kGreyLightColor = Color(0xFFE0E0E0); // Fundo dos cards
const kGreyDarkerColor = Color(0xFFBDBDBD); // Fundo dos inputs
const kDarkColor = Color(0xFF212121); // Botão Calcular
const kTextColor = Colors.black;

class PriceComparisonScreen extends StatefulWidget {
  @override
  _PriceComparisonScreenState createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  // --- Controladores e Serviços (Funcionalidade Original Mantida) ---
  final TextEditingController _quantityController1 = TextEditingController();
  final TextEditingController _priceController1 = TextEditingController();
  final TextEditingController _quantityController2 = TextEditingController();
  final TextEditingController _priceController2 = TextEditingController();
  
  final ShoppingListService _listService = ShoppingListService();
  final CartService _cartService = CartService(); 
  final PriceComparisonService _comparisonService = PriceComparisonService();

  String _baseUnit = 'g';
  String _unit1 = 'g';
  String _unit2 = 'g';
  
  // Variáveis de Resultado
  String _resultMessage = '';
  String _calculationDetails1 = '';
  String _calculationDetails2 = '';
  bool _isExpanded = false;
  bool _showResult = false;

  int _selectedIndex = 1; // Começa na tela de Comparação

  final Map<String, List<String>> _unitOptions = {
    'g': ['mg', 'g', 'kg'],
    'L': ['mL', 'L'],
    'Un': ['Un', 'Un/Pct', 'Un/Caixa'],
  };

  // --- Lógica de Navegação ---
  void _onItemTapped(int index) async {
    if (index == 0) {
      final activeList = await _listService.getActiveList();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShoppingListScreen(shoppingList: activeList)),
      );
    } else if (index == 1) {
      // Já estamos aqui
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    }
  }

  // --- Lógica de Comparação ---
  void _comparePrices() {
    // Fecha o teclado ao calcular
    FocusScope.of(context).unfocus();

    if (_quantityController1.text.isEmpty ||
        _priceController1.text.isEmpty ||
        _quantityController2.text.isEmpty ||
        _priceController2.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos.")),
      );
      return;
    }

    try {
      final result = _comparisonService.comparePrices(
        quantity1: double.parse(_quantityController1.text),
        price1: double.parse(_priceController1.text.replaceAll(',', '.')),
        unit1: _unit1,
        quantity2: double.parse(_quantityController2.text),
        price2: double.parse(_priceController2.text.replaceAll(',', '.')),
        unit2: _unit2,
        baseUnit: _baseUnit,
      );

      setState(() {
        _resultMessage = result.resultMessage;
        _calculationDetails1 = result.calculationDetails1;
        _calculationDetails2 = result.calculationDetails2;
        _showResult = true;
        _isExpanded = false; 
      });
    } catch (e) {
      setState(() {
        _resultMessage = "Por favor, insira valores válidos.";
        _calculationDetails1 = "";
        _calculationDetails2 = "";
        _showResult = true;
        _isExpanded = false;
      });
    }
  }

  void _resetFields() {
    setState(() {
      _quantityController1.clear();
      _priceController1.clear();
      _quantityController2.clear();
      _priceController2.clear();
      _resultMessage = '';
      _calculationDetails1 = '';
      _calculationDetails2 = '';
      _isExpanded = false;
      _showResult = false;
    });
  }

  void _onBaseUnitChanged(String? newValue) {
    setState(() {
      _baseUnit = newValue!;
      _unit1 = _unitOptions[_baseUnit]!.first;
      _unit2 = _unitOptions[_baseUnit]!.first;
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // --- Lógica de Adicionar ao Carrinho (Mantida intacta) ---
  Future<void> _handleAddToCart(int productNumber) async {
    final prefilledPrice = double.tryParse(
        (productNumber == 1 ? _priceController1.text : _priceController2.text).replaceAll(',', '.')
    ) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar "${productNumber == 1 ? "Produto 1" : "Produto 2"}"'),
        content: const Text('Como deseja adicionar este item ao carrinho?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addFromShoppingList(prefilledPrice);
            },
            child: const Text('De uma Lista Existente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addNewItemToCart(prefilledPrice);
            },
            child: const Text('Como um Novo Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFromShoppingList(double prefilledPrice) async {
    final ShoppingList activeList = await _listService.getActiveList();

    if (activeList.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sua lista de compras ativa está vazia.")),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione um Item da Lista'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: activeList.items.length,
            itemBuilder: (context, index) {
              final item = activeList.items[index];
              return ListTile(
                title: Text(item.name),
                onTap: () {
                  Navigator.pop(context, {'item': item, 'index': index});
                },
              );
            },
          ),
        ),
      ),
    );

    if (result != null) {
      final ShoppingListItem selectedItem = result['item'];
      final int listIndex = result['index'];
      _showAddToCartDialog(selectedItem, prefilledPrice, activeList, listIndex);
    }
  }

  Future<void> _showAddToCartDialog(ShoppingListItem item, double prefilledPrice, ShoppingList activeList, int listIndex) async {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: prefilledPrice > 0 ? prefilledPrice.toStringAsFixed(2) : '');

    final updatedItem = await showDialog<ShoppingListItem>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
         return AlertDialog(
          title: Text('Adicionar "${item.name}"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: quantityController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Quantidade inválida' : null,
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço (unidade)', prefixText: 'R\$ '),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(ShoppingListItem(
                    name: item.name,
                    quantity: int.parse(quantityController.text),
                    price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                  ));
                }
              },
            ),
          ],
        );
      },
    );

    if (updatedItem != null) {
      await _cartService.addItemToCart(updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedItem.name} adicionado ao carrinho!')),
      );
    }
  }

  Future<void> _addNewItemToCart(double prefilledPrice) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: prefilledPrice > 0 ? prefilledPrice.toStringAsFixed(2) : '');

    final newItem = await showDialog<ShoppingListItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Novo Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'O nome é obrigatório.' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Preço (unidade)', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Quantidade inválida.' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, ShoppingListItem(
                  name: nameController.text.trim(),
                  price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                  quantity: int.parse(quantityController.text),
                ));
              }
            },
            child: const Text('Adicionar'),
          )
        ],
      ),
    );

    if (newItem != null) {
      await _cartService.addItemToCart(newItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newItem.name} adicionado ao carrinho!')),
      );
    }
  }

  // --- Construção da Interface (Novo Visual) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cabeçalho Amarelo "COMPARAR"
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: kYellowColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "COMPARAR",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900, // Fonte "Black"
                      color: kTextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // 2. Seletor de Unidade Base "PRODUTO EM"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: kGreyLightColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PRODUTO EM",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kTextColor,
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: kTextColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _baseUnit,
                          icon: const Icon(Icons.keyboard_arrow_down, color: kTextColor),
                          style: const TextStyle(
                            color: kTextColor, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                          onChanged: _onBaseUnitChanged,
                          items: _unitOptions.keys.map((String key) {
                            String label = key == 'g' ? 'Massa (Kg/g)' : 
                                           key == 'L' ? 'Volume (L/mL)' : 'Unidade';
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(label),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // 3. Card ITEM 1
              _buildProductCard(
                title: "ITEM 1",
                quantityController: _quantityController1,
                priceController: _priceController1,
                unitValue: _unit1,
                onUnitChanged: (val) => setState(() => _unit1 = val!),
              ),

              const SizedBox(height: 24),

              // 4. Botão Calcular
              InkWell(
                onTap: _comparePrices,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: kDarkColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 30),
                      SizedBox(width: 12),
                      Text(
                        "CALCULAR",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Exibição dos Resultados (Só aparece se calculado) ---
              if (_showResult) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Verde claro
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade700, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Resultado Principal
                      Text(
                        _resultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade900,
                        ),
                      ),
                      // Detalhes (Expansíveis)
                      if (_calculationDetails1.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        if (!_isExpanded) 
                          TextButton.icon(
                            onPressed: _toggleExpand,
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text("Ver detalhes do cálculo"),
                          ),
                        if (_isExpanded) ...[
                          const Divider(color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            _calculationDetails1,
                            style: TextStyle(color: Colors.green.shade800, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculationDetails2,
                            style: TextStyle(color: Colors.green.shade800, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: _toggleExpand,
                            child: const Text("Ocultar detalhes"),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Adicionar ao Carrinho:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAddToCart(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kYellowColor,
                          foregroundColor: kTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text("ITEM 1", style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAddToCart(2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kYellowColor,
                          foregroundColor: kTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text("ITEM 2", style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _resetFields,
                      icon: const Icon(Icons.refresh),
                      tooltip: "Limpar tudo",
                      style: IconButton.styleFrom(backgroundColor: kGreyLightColor),
                    )
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // 5. Card ITEM 2
              _buildProductCard(
                title: "ITEM 2",
                quantityController: _quantityController2,
                priceController: _priceController2,
                unitValue: _unit2,
                onUnitChanged: (val) => setState(() => _unit2 = val!),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Método Auxiliar para Desenhar o Card do Produto (Estilo Idêntico à Imagem) ---
  Widget _buildProductCard({
    required String title,
    required TextEditingController quantityController,
    required TextEditingController priceController,
    required String unitValue,
    required Function(String?) onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGreyLightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título "ITEM X"
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Input Esquerdo: Quantidade + Unidade
              Expanded(
                flex: 5,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: kGreyDarkerColor, // Cor cinza mais escura do input
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Campo de Texto da Quantidade
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      // Dropdown da Unidade
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: unitValue,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          style: const TextStyle(color: kTextColor, fontSize: 14),
                          onChanged: onUnitChanged,
                          items: _unitOptions[_baseUnit]!.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              // Input Direito: Preço
              Expanded(
                flex: 4,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kGreyDarkerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text("R\$", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}