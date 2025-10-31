// lib/services/price_comparison_service.dart
import 'package:compracerta/models/comparison_result.dart'; // Atualize 'seu_projeto'


class PriceComparisonService {
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

  ComparisonResult comparePrices({
    required double quantity1,
    required double price1,
    required String unit1,
    required double quantity2,
    required double price2,
    required String unit2,
    required String baseUnit,
  }) {
    final convertedQuantity1 = _convertToBaseUnit(unit1, quantity1);
    final convertedQuantity2 = _convertToBaseUnit(unit2, quantity2);

    final unitPrice1 = price1 / convertedQuantity1;
    final unitPrice2 = price2 / convertedQuantity2;

    final calculationDetails1 =
        'R\$ ${price1.toStringAsFixed(2)} / ${convertedQuantity1.toStringAsFixed(2)} $baseUnit \n= R\$ ${unitPrice1.toStringAsFixed(2)} por $baseUnit\n';
    final calculationDetails2 =
        'R\$ ${price2.toStringAsFixed(2)} / ${convertedQuantity2.toStringAsFixed(2)} $baseUnit \n= R\$ ${unitPrice2.toStringAsFixed(2)} por $baseUnit';

    String resultMessage;
    if (unitPrice1 < unitPrice2) {
      resultMessage = "Produto 1";
    } else if (unitPrice1 > unitPrice2) {
      resultMessage = "Produto 2";
    } else {
      resultMessage = "Mesmo preço.";
    }

    return ComparisonResult(
      resultMessage: resultMessage,
      calculationDetails1: calculationDetails1,
      calculationDetails2: calculationDetails2,
    );
  }
}