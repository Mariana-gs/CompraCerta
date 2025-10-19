// lib/screens/shopping_list_screen.dart
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/widgets/shopping_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Importe o pacote

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  // A lista agora começa vazia e será preenchida com os dados salvos
  final List<ShoppingListItem> _items = [];
  static const String _itemsKey = 'shopping_items_list'; // Chave para salvar os dados

  @override
  void initState() {
    super.initState();
    _loadItems(); // 2. Carrega os itens quando a tela é iniciada
  }

  // 3. Método para CARREGAR os itens da memória
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Lê a lista de strings salva no dispositivo
    final List<String> savedItems = prefs.getStringList(_itemsKey) ?? [];
    setState(() {
      // Converte a lista de strings de volta para uma lista de ShoppingListItem
      _items.clear();
      _items.addAll(savedItems.map((name) => ShoppingListItem(name: name)));
    });
  }

  // 4. Método para SALVAR os itens na memória
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Converte a lista de ShoppingListItem para uma lista de strings (só os nomes)
    final List<String> itemNames = _items.map((item) => item.name).toList();
    await prefs.setStringList(_itemsKey, itemNames);
  }

  void _addItem() {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Item'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Nome do produto"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                final String itemName = textController.text.trim();
                if (itemName.isNotEmpty) {
                  setState(() {
                    _items.add(ShoppingListItem(name: itemName));
                  });
                  _saveItems(); // 5. Salva a lista após adicionar um item
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems(); // 6. Salva a lista após remover um item
  }

  void _addToCart(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_items[index].name} movido para o carrinho!')),
    );
  }

  // O resto do código (o método build e os sub-widgets) permanece exatamente o mesmo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text("Sua lista está vazia!"))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return ShoppingListItemWidget(
                            itemName: _items[index].name,
                            onDelete: () => _deleteItem(index),
                            onAddToCart: () => _addToCart(index),
                          );
                        },
                      ),
              ),
              _buildAddItemButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF79E89),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                'MINHA LISTA',
                style: GoogleFonts.bungee(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'NOVO ITEM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
      ),
    );
  }
}