// lib/widgets/base_unit_selector.dart
import 'package:flutter/material.dart';

class BaseUnitSelector extends StatelessWidget {
  final String baseUnit;
  final List<String> unitKeys;
  final ValueChanged<String?> onChanged;

  const BaseUnitSelector({
    Key? key,
    required this.baseUnit,
    required this.unitKeys,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: EdgeInsets.only(left: 32),
            child: Text(
              'Medida Base',
              style: TextStyle(fontSize: 18, fontFamily: 'Outfit'),
            ),
          ),
          Container(
            width: 101,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButton<String>(
                value: baseUnit,
                onChanged: onChanged,
                items: unitKeys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                underline: SizedBox(),
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}