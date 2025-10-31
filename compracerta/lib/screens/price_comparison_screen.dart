// lib/screens/price_comparison_screen.dart
import 'package:flutter/material.dart';
import 'package:compracerta/models/comparison_result.dart'; 
import 'package:compracerta/services/price_comparison_service.dart'; 
import 'package:compracerta/widgets/base_unit_selector.dart'; 
import 'package:compracerta/widgets/calculation_result_button.dart'; 
import 'package:compracerta/widgets/product_input_card.dart'; 
import 'package:compracerta/widgets/custom_bottom_nav_bar.dart';
import 'package:compracerta/screens/shopping_list_screen.dart';
import 'package:compracerta/services/shopping_list_service.dart';
import 'package:compracerta/screens/cart_screen.dart';
import 'package:compracerta/models/shopping_list.dart';
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/services/cart_service.dart';
import 'package:flutter/services.dart';
import 'package:compracerta/widgets/comparison_product_result_card.dart';


class PriceComparisonScreen extends StatefulWidget {
  @override
  _PriceComparisonScreenState createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final TextEditingController _quantityController1 = TextEditingController();
  final TextEditingController _priceController1 = TextEditingController();
  final TextEditingController _quantityController2 = TextEditingController();
  final TextEditingController _priceController2 = TextEditingController();
  final ShoppingListService _listService = ShoppingListService();
  final CartService _cartService = CartService(); // Serviço do carrinho
  final PriceComparisonService _comparisonService = PriceComparisonService();
  

 

  String _baseUnit = 'g';
  String _unit1 = 'g';
  String _unit2 = 'g';
  String _resultMessage = '';
  String _calculationDetails1 = '';
  String _calculationDetails2 = '';
  bool _isExpanded = false;
  bool _showResult = false;
  bool _isArrowDown = false;
  bool _showDownArrowButton = false;

  // 2. ADICIONE UMA VARIÁVEL DE ESTADO PARA O ÍNDICE SELECIONADO
  int _selectedIndex = 1; // Começa com o item do meio selecionado

 void _onItemTapped(int index) async {
    if (index == 0) {
      // Carrega a lista ativa do dispositivo e navega para a tela
      final activeList = await _listService.getActiveList();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShoppingListScreen(shoppingList: activeList)),
      );
    }
    // index 1 é a tela atual de Comparação, então não fazemos nada
    else if (index == 1) {
      // print("Já estamos na tela de comparação.");
    }
    // index 2 agora navega para a tela de Carrinho
    else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    }
  }
  final Map<String, List<String>> _unitOptions = {
    'g': ['mg', 'g', 'kg'],
    'L': ['mL', 'L'],
    'Un': ['Un', 'Un/Pct', 'Un/Caixa'],
  };

  void _comparePrices() {
    if (_quantityController1.text.isEmpty ||
        _priceController1.text.isEmpty ||
        _quantityController2.text.isEmpty ||
        _priceController2.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos.")),
      );
      return;
    }

    try {
      final result = _comparisonService.comparePrices(
        quantity1: double.parse(_quantityController1.text),
        price1: double.parse(_priceController1.text),
        unit1: _unit1,
        quantity2: double.parse(_quantityController2.text),
        price2: double.parse(_priceController2.text),
        unit2: _unit2,
        baseUnit: _baseUnit,
      );

      setState(() {
        _resultMessage = result.resultMessage;
        _calculationDetails1 = result.calculationDetails1;
        _calculationDetails2 = result.calculationDetails2;
        _showResult = true;
        _isExpanded = false; // Começa fechado para o usuário abrir se quiser
        _showDownArrowButton = true;
        _isArrowDown = false;
      });
    } catch (e) {
      setState(() {
        _resultMessage = "Por favor, insira valores válidos.";
        _calculationDetails1 = "";
        _calculationDetails2 = "";
        _showResult = true;
        _isExpanded = false;
        _showDownArrowButton = false;
      });
    }
  }


  Future<void> _handleAddToCart(int productNumber) async {
    final prefilledPrice = double.tryParse(
        productNumber == 1 ? _priceController1.text : _priceController2.text
    ) ?? 0.0;

    // Mostra o diálogo de escolha inicial
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

    // Mostra um diálogo para o usuário selecionar o item
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

    // Se um item foi selecionado, continua o fluxo
    if (result != null) {
      final ShoppingListItem selectedItem = result['item'];
      final int listIndex = result['index'];
      _showAddToCartDialog(selectedItem, prefilledPrice, activeList, listIndex);
    }
  }

  /// 3a. Diálogo final para "Adicionar da Lista": Pede quantidade e confirma.
 Future<void> _showAddToCartDialog(ShoppingListItem item, double prefilledPrice, ShoppingList activeList, int listIndex) async {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: prefilledPrice > 0 ? prefilledPrice.toStringAsFixed(2) : '');

    // O diálogo para pegar quantidade e preço continua o mesmo
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

    // Se o usuário confirmou e um item foi criado
    if (updatedItem != null) {
      // 1. Adicionamos o item ao carrinho. Esta é a única ação necessária.
      await _cartService.addItemToCart(updatedItem);

      // --- AS LINHAS ABAIXO FORAM REMOVIDAS ---
      // activeList.items.removeAt(listIndex);  <-- REMOVIDO
      // final allLists = await _listService.getLists(); <-- REMOVIDO
      // final index = allLists.indexWhere((list) => list.name == activeList.name); <-- REMOVIDO
      // if (index != -1) { <-- REMOVIDO
      //   allLists[index] = activeList; <-- REMOVIDO
      //   await _listService.saveLists(allLists); <-- REMOVIDO
      // } <-- REMOVIDO

      // 2. Mostramos a confirmação para o usuário.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedItem.name} adicionado ao carrinho!')),
      );
    }
  }

  /// 2b. Fluxo "Adicionar como Novo Item": Mostra o diálogo de adição rápida.
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
      _showDownArrowButton = false;
      _isArrowDown = false;
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
      _isArrowDown = !_isArrowDown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Column(
        children: [
          SizedBox(height: 56),
          Center(child: Text("Compra Certa")),
          SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BaseUnitSelector(
                      baseUnit: _baseUnit,
                      unitKeys: _unitOptions.keys.toList(),
                      onChanged: _onBaseUnitChanged,
                    ),
                    SizedBox(height: 32),
                    ProductInputCard(
                      title: 'PRODUTO 1',
                      quantityController: _quantityController1,
                      priceController: _priceController1,
                      selectedUnit: _unit1,
                      unitOptions: _unitOptions[_baseUnit]!,
                      onUnitChanged: (newValue) {
                        setState(() => _unit1 = newValue!);
                      },
                    ),
                    SizedBox(height: 20),
                    CalculationResultButton(
                      isExpanded: _isExpanded,
                      showResult: _showResult,
                      resultMessage: _resultMessage,
                      calculationDetails1: _calculationDetails1,
                      calculationDetails2: _calculationDetails2,
                      isArrowDown: _isArrowDown,
                      showDownArrowButton: _showDownArrowButton,
                      onCalculate: _comparePrices,
                      onToggleExpand: _toggleExpand,
                      onReset: _resetFields,
                    ),
                    if (_showResult && _resultMessage.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Adicionar um dos produtos ao carrinho:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Produto 1'),
                            onPressed: () => _handleAddToCart(1),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Produto 2'),
                            onPressed: () => _handleAddToCart(2),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white),
                          ),
                        ],
                      )
                    ],

                    const SizedBox(height: 20),
                    ProductInputCard(
                      title: 'PRODUTO 2',
                      quantityController: _quantityController2,
                      priceController: _priceController2,
                      selectedUnit: _unit2,
                      unitOptions: _unitOptions[_baseUnit]!,
                      onUnitChanged: (newValue) {
                        setState(() => _unit2 = newValue!);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
}