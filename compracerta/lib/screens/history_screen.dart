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
  List<PurchaseHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
   _loadHistory();
    
  }
  
  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; });
    final history = await _historyService.getHistory();
    setState(() {
      _historyList = history;
      _isLoading = false;
    });
  }


Future<void> _deleteItem(String purchaseId) async {
    // Pede confirmação ao usuário
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta compra do seu histórico? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    // Se o usuário confirmou, procede com a exclusão
    if (confirmDelete == true) {
      await _historyService.deletePurchase(purchaseId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra excluída com sucesso!')),
      );
      // Recarrega a lista para refletir a mudança na UI
      await _loadHistory();
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(child: Text('Nenhuma compra no histórico.'))
              : ListView.builder(
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final purchase = _historyList[index];
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
                        onTap: () {
                          // Retorna a compra para ser editada na tela do carrinho
                          Navigator.of(context).pop(purchase);
                        },
                        // TRAILING ATUALIZADO COM O BOTÃO DE EXCLUSÃO
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteItem(purchase.id),
                          tooltip: 'Excluir Compra',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}