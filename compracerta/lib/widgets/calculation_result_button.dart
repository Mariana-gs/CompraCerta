// lib/widgets/calculation_result_button.dart
import 'package:flutter/material.dart';

class CalculationResultButton extends StatelessWidget {
  final bool isExpanded;
  final bool showResult;
  final bool isArrowDown;
  final bool showDownArrowButton;
  final String resultMessage;
  final String calculationDetails1;
  final String calculationDetails2;
  final VoidCallback onCalculate;
  final VoidCallback onToggleExpand;
  final VoidCallback onReset;

  const CalculationResultButton({
    Key? key,
    required this.isExpanded,
    required this.showResult,
    required this.isArrowDown,
    required this.showDownArrowButton,
    required this.resultMessage,
    required this.calculationDetails1,
    required this.calculationDetails2,
    required this.onCalculate,
    required this.onToggleExpand,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onCalculate,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isExpanded ? 292 : 64,
              decoration: BoxDecoration(
                color: showResult ? Color(0xFFF77563) : Colors.black,
                borderRadius: BorderRadius.circular(32),
              ),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isExpanded ? 0 : (64 - (showResult ? 50 : 20)) / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              showResult ? resultMessage : 'CALCULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: showResult ? 24 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (showResult && resultMessage != "Mesmo preço.")
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
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            SizedBox(height: 17),
                            Container(
                              width: 289,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.only(top: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Produto 1", style: TextStyle(color: Colors.black, fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(calculationDetails1, style: TextStyle(color: Colors.black, fontSize: 14), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 289,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.only(bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Produto 2", style: TextStyle(color: Colors.black, fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(calculationDetails2, style: TextStyle(color: Colors.black, fontSize: 14), textAlign: TextAlign.center),
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
          ),
          if (showDownArrowButton)
            Positioned(
              left: 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(isArrowDown ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white),
                  onPressed: onToggleExpand,
                ),
              ),
            ),
          if (showDownArrowButton)
            Positioned(
              right: 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.black),
                  onPressed: onReset,
                ),
              ),
            ),
        ],
      ),
    );
  }
}