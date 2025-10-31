// lib/screens/shopping_list_screen.dart
import 'package:compracerta/models/shopping_list.dart';
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/screens/list_management_screen.dart';
import 'package:compracerta/services/shopping_list_service.dart';
import 'package:compracerta/widgets/shopping_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compracerta/services/cart_service.dart';
import 'package:flutter/services.dart';

class ShoppingListScreen extends StatefulWidget {
  // Recebe a lista inicial a ser exibida
  final ShoppingList shoppingList;
  const ShoppingListScreen({Key? key, required this.shoppingList}) : super(key: key);

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  // Variáveis de estado
  late ShoppingList _currentList;
  final ShoppingListService _listService = ShoppingListService();
Set<String> _itemsInCart = {};
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Inicializa a lista da tela com a que foi passada pelo widget
    _currentList = widget.shoppingList;
    _loadCartStatus();
  }

Future<void> _loadCartStatus() async {
    final cartItems = await _cartService.getCart();
    // Usamos um Set para uma verificação mais rápida (O(1))
    setState(() {
      _itemsInCart = cartItems.map((item) => item.name).toSet();
    });
  }

  // Salva as alterações feitas na lista atual no armazenamento do dispositivo
  Future<void> _saveChanges() async {
    final allLists = await _listService.getLists();
    // Encontra o índice da lista atual na lista de todas as listas
    final index = allLists.indexWhere((list) => list.name == _currentList.name);

    if (index != -1) {
      // Se encontrou, substitui a lista antiga pela nova (com os itens atualizados)
      allLists[index] = _currentList;
      await _listService.saveLists(allLists);
    }
  }

  // Adiciona um novo item à lista
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
                    _currentList.items.add(ShoppingListItem(name: itemName));
                  });
                  _saveChanges(); // Salva as alterações
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<ShoppingListItem?> _showAddToCartDialog(ShoppingListItem item) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController priceController = TextEditingController();

    return showDialog<ShoppingListItem>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar nos botões para fechar
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar "${item.name}"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Campo de Quantidade
                TextFormField(
                  controller: quantityController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    hintText: 'Ex: 1',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Insira uma quantidade válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de Preço
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Preço (Opcional)',
                    hintText: 'Ex: 12.99',
                    prefixText: 'R\$ ',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Retorna nulo
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Cria uma nova instância do item com os dados do popup
                  final updatedItem = ShoppingListItem(
                    name: item.name,
                    quantity: int.parse(quantityController.text),
                    price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                  );
                  Navigator.of(context).pop(updatedItem); // Retorna o item atualizado
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Deleta um item da lista
void _deleteItem(int index) async {
    // Adicional: remove o item do carrinho se ele for deletado da lista
    final itemNameToDelete = _currentList.items[index].name;

    setState(() {
      _currentList.items.removeAt(index);
    });
    await _saveChanges(); // Salva a remoção da lista

    // Opcional: para deletar da lista, delete também do carrinho
    // final cartItems = await _cartService.getCart();
    // final cartIndex = cartItems.indexWhere((item) => item.name == itemNameToDelete);
    // if (cartIndex != -1) {
    //   await _cartService.removeItemFromCart(cartIndex);
    // }
    // await _loadCartStatus(); // Recarrega o status do carrinho
  }

  // Adiciona um item ao carrinho (lógica a ser implementada)
void _addToCart(int index) async {
    final itemToAdd = _currentList.items[index];
    final updatedItem = await _showAddToCartDialog(itemToAdd);

    if (updatedItem != null) {
      await _cartService.addItemToCart(updatedItem);

      // EM VEZ DE REMOVER, ATUALIZAMOS O ESTADO DO CARRINHO
      await _loadCartStatus(); // Isso vai recarregar a lista e redesenhar o item como "no carrinho"

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedItem.name} adicionado ao carrinho!')),
      );
    }
  }




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
                child: _currentList.items.isEmpty
                    ? const Center(child: Text("Sua lista está vazia!\nAdicione um novo item abaixo."))
                    : ListView.builder(
                        itemCount: _currentList.items.length,
                        itemBuilder: (context, index) {
                          final item = _currentList.items[index];
                          // VERIFICA SE O ITEM ESTÁ NO NOSSO SET DE ITENS DO CARRINHO
                          final bool itemIsInCart = _itemsInCart.contains(item.name);

                          return ShoppingListItemWidget(
                            itemName: item.name,
                            isInCart: itemIsInCart, // PASSA A INFORMAÇÃO PARA O WIDGET
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
  // Constrói o cabeçalho da tela
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
                _currentList.name.toUpperCase(), // Exibe o nome da lista atual
                style: GoogleFonts.bungee(color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Botão para navegar para a tela de gerenciamento de listas
        IconButton(
          icon: const Icon(Icons.edit_note, size: 30),
          onPressed: () async {
            // Navega para a tela de gerenciamento
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListManagementScreen()),
            );
            // Ao retornar, recarrega a lista ativa para refletir qualquer mudança
            final activeList = await _listService.getActiveList();
            setState(() {
              _currentList = activeList;
            });
          },
        ),
      ],
    );
  }

  // Constrói o botão de adicionar novo item
  Widget _buildAddItemButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'NOVO ITEM',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
        ),
      ),
    );
  }
}