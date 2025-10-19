// lib/widgets/product_input_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductInputCard extends StatelessWidget {
  final String title;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final String selectedUnit;
  final List<String> unitOptions;
  final ValueChanged<String?> onUnitChanged;

  const ProductInputCard({
    Key? key,
    required this.title,
    required this.quantityController,
    required this.priceController,
    required this.selectedUnit,
    required this.unitOptions,
    required this.onUnitChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 26.5),
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
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5),
                        hintText: '0',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 122,
                  height: 41,
                  padding: EdgeInsets.only(left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    onChanged: onUnitChanged,
                    items: unitOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: SizedBox(),
                    isExpanded: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 41,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                controller: priceController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money),
                        SizedBox(width: 4),
                        Text('R\$'),
                      ],
                    ),
                  ),
                  contentPadding: EdgeInsets.only(top: 8, right: 10),
                  hintText: '0',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}