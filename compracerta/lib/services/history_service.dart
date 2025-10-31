// lib/services/history_service.dart
import 'dart:convert';
import 'package:compracerta/models/purchase_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _historyKey = 'purchase_history_list';

  // Carrega toda a lista de histórico
  Future<List<PurchaseHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson
        .map((json) => PurchaseHistory.fromJson(jsonDecode(json)))
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Ordena do mais recente para o mais antigo
  }

  // Salva a lista de histórico
  Future<void> _saveHistory(List<PurchaseHistory> historyList) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson =
        historyList.map((purchase) => jsonEncode(purchase.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }

  // Adiciona uma nova compra ao histórico
  Future<void> addPurchaseToHistory(PurchaseHistory purchase) async {
    final historyList = await getHistory();
    historyList.add(purchase);
    await _saveHistory(historyList);
  }

  Future<void> updatePurchase(PurchaseHistory updatedPurchase) async {
    final historyList = await getHistory();
    // Encontra o índice da compra que tem o mesmo ID
    final index = historyList.indexWhere((p) => p.id == updatedPurchase.id);

    if (index != -1) {
      // Se encontrou, substitui a compra antiga pela nova
      historyList[index] = updatedPurchase;
      await _saveHistory(historyList);
    }
  }



}