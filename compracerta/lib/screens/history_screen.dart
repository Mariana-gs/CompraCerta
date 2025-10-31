// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:compracerta/models/purchase_history.dart';
import 'package:compracerta/services/history_service.dart';
import 'package:intl/intl.dart'; // Adicione o pacote intl: flutter pub add intl

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<PurchaseHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: FutureBuilder<List<PurchaseHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar o histórico.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma compra no histórico.'));
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final purchase = historyList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    purchase.supermarketName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(purchase.date)} - R\$ ${purchase.total.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Retorna a compra selecionada para a tela do carrinho
                    Navigator.of(context).pop(purchase);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}