// lib/screens/list_management_screen.dart
import 'package:compracerta/models/shopping_list.dart';
import 'package:compracerta/services/shopping_list_service.dart';
import 'package:flutter/material.dart';

class ListManagementScreen extends StatefulWidget {
  const ListManagementScreen({Key? key}) : super(key: key);

  @override
  _ListManagementScreenState createState() => _ListManagementScreenState();
}

class _ListManagementScreenState extends State<ListManagementScreen> {
  final ShoppingListService _listService = ShoppingListService();
  List<ShoppingList> _lists = [];
  String _activeListName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final lists = await _listService.getLists();
    final activeList = await _listService.getActiveList();
    setState(() {
      _lists = lists;
      _activeListName = activeList.name;
    });
  }

  Future<void> _createNewList() async {
    final TextEditingController textController = TextEditingController();
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista de Compras'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Compras do Mês'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _lists.add(ShoppingList(name: newName, items: []));
      });
      await _listService.saveLists(_lists);
    }
  }

  Future<void> _deleteList(int index) async {
    final listToDelete = _lists[index];
    setState(() {
      _lists.removeAt(index);
    });
    await _listService.saveLists(_lists);

    // Se a lista deletada era a ativa, define a primeira como nova ativa
    if (listToDelete.name == _activeListName) {
      await _listService.setActiveList(_lists.first.name);
    }
    _loadData(); // Recarrega os dados para atualizar a UI
  }

  Future<void> _selectActiveList(int index) async {
    final newActiveList = _lists[index];
    await _listService.setActiveList(newActiveList.name);
    setState(() {
      _activeListName = newActiveList.name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${newActiveList.name}" é a nova lista ativa!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Listas'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final list = _lists[index];
          final bool isActive = list.name == _activeListName;
          return ListTile(
            title: Text(list.name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            leading: Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: Theme.of(context).primaryColor),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _lists.length > 1 ? () => _deleteList(index) : null, // Não permite deletar a última lista
            ),
            onTap: () => _selectActiveList(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewList,
        label: const Text('Nova Lista'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}