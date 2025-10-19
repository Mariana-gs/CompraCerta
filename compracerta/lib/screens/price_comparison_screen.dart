// lib/screens/price_comparison_screen.dart
import 'package:flutter/material.dart';
import 'package:compracerta/models/comparison_result.dart'; // Atualize
import 'package:compracerta/services/price_comparison_service.dart'; // Atualize
import 'package:compracerta/widgets/base_unit_selector.dart'; // Atualize
import 'package:compracerta/widgets/calculation_result_button.dart'; // Atualize
import 'package:compracerta/widgets/product_input_card.dart'; // Atualize
import 'package:compracerta/widgets/custom_bottom_nav_bar.dart';
import 'package:compracerta/screens/shopping_list_screen.dart';

class PriceComparisonScreen extends StatefulWidget {
  @override
  _PriceComparisonScreenState createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final TextEditingController _quantityController1 = TextEditingController();
  final TextEditingController _priceController1 = TextEditingController();
  final TextEditingController _quantityController2 = TextEditingController();
  final TextEditingController _priceController2 = TextEditingController();

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

  // Função para lidar com o toque nos itens
 void _onItemTapped(int index) {
    // index 0 é a tela de Lista
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
      );
    }
    // index 1 é a tela atual de Comparação, então não fazemos nada
    else if (index == 1) {
      print("Já estamos na tela de comparação.");
    }
    // index 2 seria a tela de Carrinho (ainda não implementada)
    else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tela do Carrinho ainda não implementada.")),
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
                    SizedBox(height: 20),
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