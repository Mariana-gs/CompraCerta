import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Garante que os bindings do Flutter sejam inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicia o aplicativo.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador de Preços',
      home: PriceComparisonScreen(),
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      theme: ThemeData(
        fontFamily: 'Outfit', // Define a fonte padrão
      ),
    );
  }
}

class PriceComparisonScreen extends StatefulWidget {
  @override
  _PriceComparisonScreenState createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  // Mantém os controladores e outras variáveis de estado.
  final TextEditingController _quantityController1 = TextEditingController();
  final TextEditingController _priceController1 = TextEditingController();
  final TextEditingController _quantityController2 = TextEditingController();
  final TextEditingController _priceController2 = TextEditingController();

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

  final Map<String, List<String>> _unitOptions = {
    'g': ['mg', 'g', 'kg'],
    'L': ['mL', 'L'],
    'Un': ['Un', 'Un/Pct', 'Un/Caixa'],
  };

  double _convertToBaseUnit(String unit, double value) {
    switch (unit) {
      case 'kg':
        return value * 1000; // kg para g
      case 'mg':
        return value / 1000; // mg para g
      case 'L':
        return value; // L permanece igual
      case 'mL':
        return value / 1000; // mL para L
      case 'Un/Pct':
      case 'Un/Caixa':
      case 'Un':
        return value;
      default:
        return value;
    }
  }

  void _comparePrices() {
    try {
      double quantity1 = double.parse(_quantityController1.text);
      double price1 = double.parse(_priceController1.text);
      double quantity2 = double.parse(_quantityController2.text);
      double price2 = double.parse(_priceController2.text);

      double convertedQuantity1 = _convertToBaseUnit(_unit1, quantity1);
      double convertedQuantity2 = _convertToBaseUnit(_unit2, quantity2);

      double unitPrice1 = price1 / convertedQuantity1;
      double unitPrice2 = price2 / convertedQuantity2;

      _calculationDetails1 =
          'R\$ ${price1.toStringAsFixed(2)} / ${convertedQuantity1.toStringAsFixed(2)} $_baseUnit \n= R\$ ${unitPrice1.toStringAsFixed(2)} por $_baseUnit\n';
      _calculationDetails2 =
          'R\$ ${price2.toStringAsFixed(2)} / ${convertedQuantity2.toStringAsFixed(2)} $_baseUnit \n= R\$ ${unitPrice2.toStringAsFixed(2)} por $_baseUnit';

      if (unitPrice1 < unitPrice2) {
        _resultMessage = "Produto 1";
      } else if (unitPrice1 > unitPrice2) {
        _resultMessage = "Produto 2";
      } else {
        _resultMessage = "Mesmo preço.";
      }
    } catch (e) {
      _resultMessage = "Por favor, insira valores válidos.";
      _calculationDetails1 = "";
      _calculationDetails2 = "";
    }

    setState(() {
      _showResult = true;
      _isExpanded = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          SizedBox(height: 56),
          Center(
            child: Text("Compra Certa"),
            //Image.asset('assets/valorexato.png', width: 106, height: 39),
          ),
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
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      padding: EdgeInsets.only(left: 16.0),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 32,
                            ), // Afastamento de 32 pixels do lado esquerdo
                            child: Text(
                              'Medida Base',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                          Container(
                            width: 101, // Largura do Container
                            height: 48, // Altura do Container
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.black,
                              ), // Borda preta
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                              ), // Espaço de 15 pixels
                              child: DropdownButton<String>(
                                value: _baseUnit,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _baseUnit = newValue!;
                                    _unit1 = _unitOptions[_baseUnit]!.first;
                                    _unit2 = _unitOptions[_baseUnit]!.first;
                                  });
                                },
                                items:
                                    _unitOptions.keys
                                        .map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        })
                                        .toList(),
                                underline:
                                    SizedBox(), // Remove a linha sublinhada
                                isExpanded:
                                    true, // Garante que o Dropdown ocupe o espaço disponível
                              ),
                            ), // Fim do Padding
                          ), // Fim do Container principal
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Produto 1
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        width: 328,
                        height: 189,
                        decoration: BoxDecoration(
                          color: Color(0xFFFCE1AC),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 16,
                          left: 32,
                          right: 32,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .center, // Centraliza o conteúdo horizontalmente
                          children: [
                            // Centraliza o texto "PRODUTO 1" na linha
                            Center(
                              child: Text(
                                'PRODUTO 1',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 26.5),
                            // Campo de texto para quantidade e o DropdownButton na mesma linha
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 41,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: TextField(
                                      controller: _quantityController1,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        hintText: '0',
                                        border: InputBorder.none,
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d*'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // DropdownButton para a unidade de medida
                                Container(
                                  width: 122,
                                  height: 41,
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _unit1,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _unit1 = newValue!;
                                      });
                                    },
                                    items:
                                        _unitOptions[_baseUnit]!
                                            .map<DropdownMenuItem<String>>((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            })
                                            .toList(),
                                    underline:
                                        SizedBox(), // Remove a linha sublinhada
                                    isExpanded: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Campo de texto para o preço
                            Container(
                              height: 41,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: TextField(
                                controller: _priceController1,
                                textAlign:
                                    TextAlign.right, // Alinha o texto à direita
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                        ), // Ícone de cifrão
                                        SizedBox(
                                          width: 4,
                                        ), // Espaçamento entre o ícone e o texto
                                        Text('R\$'), // Texto de cifrão
                                      ],
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 8,
                                    right: 10,
                                  ),
                                  hintText: '0',
                                  border:
                                      InputBorder
                                          .none, // Remove a borda inferior
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Botão de calcular ocupando toda a largura
                    Container(
                      width: 328,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_quantityController1.text.isNotEmpty &&
                                  _priceController1.text.isNotEmpty &&
                                  _quantityController2.text.isNotEmpty &&
                                  _priceController2.text.isNotEmpty) {
                                _comparePrices();
                                setState(() {
                                  _showDownArrowButton =
                                      true; // Mostra o botão de seta ao calcular
                                  _isExpanded =
                                      false; // Define a expansão como falsa
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Por favor, preencha todos os campos.",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              height: _isExpanded ? 292 : 64,
                              decoration: BoxDecoration(
                                color:
                                    _showResult
                                        ? Color(0xFFF77563)
                                        : Colors.black,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            _showResult
                                                ? _resultMessage
                                                : 'CALCULAR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: _showResult ? 24 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_showResult &&
                                              _resultMessage != "Mesmo preço.")
                                            Text(
                                              'é mais barato!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (_isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 17),
                                          // Primeiro contêiner para calculationDetails1
                                          Container(
                                            width: 289,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            padding: EdgeInsets.only(top: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Produto 1",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  _calculationDetails1,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Segundo contêiner para calculationDetails2
                                          Container(
                                            width: 289,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Produto 2",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  _calculationDetails2,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_showDownArrowButton)
                            Positioned(
                              left: 0,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isArrowDown
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded =
                                          !_isExpanded; // Alterna a expansão do botão
                                      _isArrowDown =
                                          !_isArrowDown; // Alterna o ícone da seta
                                    });
                                  },
                                ),
                              ),
                            ),
                          if (_showDownArrowButton)
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _resetFields();
                                    setState(() {
                                      _showDownArrowButton = false;
                                      _isExpanded = false;
                                      _isArrowDown =
                                          false; // Reseta o estado da seta
                                    });
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Produto 2
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        width: 328,
                        height: 189,
                        decoration: BoxDecoration(
                          color: Color(0xFFFCE1AC),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 16,
                          left: 32,
                          right: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Centraliza o texto "PRODUTO 2" na linha
                            Center(
                              child: Text(
                                'PRODUTO 2',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 26.5),
                            // Campo de texto para quantidade e o DropdownButton na mesma linha
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 41,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: TextField(
                                      controller: _quantityController2,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        hintText: '0',
                                        border:
                                            InputBorder
                                                .none, // Remove a borda inferior
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d*'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // DropdownButton para a unidade de medida
                                Container(
                                  width: 122,
                                  height: 41,
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _unit2,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _unit2 = newValue!;
                                      });
                                    },
                                    items:
                                        _unitOptions[_baseUnit]!
                                            .map<DropdownMenuItem<String>>((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            })
                                            .toList(),
                                    underline:
                                        SizedBox(), // Remove a linha sublinhada
                                    isExpanded: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Campo de texto para o preço
                            Container(
                              height: 41,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: TextField(
                                controller: _priceController2,
                                textAlign:
                                    TextAlign.right, // Alinha o texto à direita
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                        ), // Ícone de cifrão
                                        SizedBox(
                                          width: 4,
                                        ), // Espaçamento entre o ícone e o texto
                                        Text('R\$'), // Texto de cifrão
                                      ],
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 8,
                                    right: 10,
                                  ),
                                  hintText: '0',
                                  border:
                                      InputBorder
                                          .none, // Remove a borda inferior
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // O Container do banner foi removido daqui.
        ],
      ),
    );
  }
}
