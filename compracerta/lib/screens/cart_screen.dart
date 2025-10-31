// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:compracerta/models/purchase_history.dart'; // Importe o novo modelo
import 'package:compracerta/models/shopping_list_item.dart';
import 'package:compracerta/services/cart_service.dart';
import 'package:compracerta/services/history_service.dart'; // Importe o novo serviço
import 'package:compracerta/widgets/cart_item_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart'; 
import 'package:compracerta/screens/history_screen.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final HistoryService _historyService = HistoryService();
  List<ShoppingListItem> _cartItems = [];
  double _budget = 0.0;
  double _total = 0.0;
  bool _isLoading = true;

  PurchaseHistory? _editingPurchase; // Se não for nulo, estamos em modo de edição
  List<ShoppingListItem> _cartBeforeEdit = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    final items = await _cartService.getCart();
    final budget = await _cartService.getBudget();
    setState(() {
      _cartItems = items;
      _budget = budget;
      _calculateTotal();
      _isLoading = false;
    });
  }

/// Salva a compra no histórico ou atualiza uma compra existente em modo de edição.
Future<void> _saveOrCompletePurchase() async {
    if (_editingPurchase != null) {
      final updatedPurchase = PurchaseHistory(
        id: _editingPurchase!.id,
        supermarketName: _editingPurchase!.supermarketName,
        items: List.from(_cartItems),
        total: _total,
        budget: _budget,
        date: DateTime.now(),
      );
      await _historyService.updatePurchase(updatedPurchase);
      setState(() {
        _editingPurchase = null;
        _cartItems = _cartBeforeEdit;
        _cartBeforeEdit = [];
        _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra atualizada com sucesso!')),
      );
    } else {
      if (_cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O carrinho está vazio!')),
        );
        return;
      }
      final supermarketName = await _showSupermarketDialog();
      if (supermarketName != null && supermarketName.isNotEmpty) {
        final newPurchase = PurchaseHistory(
          id: const Uuid().v4(),
          supermarketName: supermarketName,
          items: List.from(_cartItems),
          total: _total,
          budget: _budget,
          date: DateTime.now(),
        );
        await _historyService.addPurchaseToHistory(newPurchase);
        await _cartService.clearCart();
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra em "$supermarketName" salva no histórico!')),
        );
      }
    }
  }


Future<void> _completePurchase() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O carrinho está vazio!')),
      );
      return;
    }

    final supermarketName = await _showSupermarketDialog();

    if (supermarketName != null && supermarketName.isNotEmpty) {
      final newPurchase = PurchaseHistory(
        id: const Uuid().v4(), // Gera um ID único
        supermarketName: supermarketName,
        items: List.from(_cartItems), // Cria uma cópia da lista
        total: _total,
        budget: _budget,
        date: DateTime.now(),
      );

      await _historyService.addPurchaseToHistory(newPurchase);
      await _cartService.clearCart(); // Limpa o carrinho atual
      await _loadData(); // Recarrega a tela (que agora estará vazia)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Compra em "$supermarketName" salva no histórico!')),
      );
    }
  }
  // --- NOVO DIÁLOGO PARA NOME DO SUPERMERCADO ---
  Future<String?> _showSupermarketDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Compra'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Nome do Supermercado'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  
  void _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    setState(() { _total = total; });
  }


  void _updateItem(int index, ShoppingListItem item) {
    setState(() {
      _cartItems[index] = item;
    });
    // SÓ SALVA NO CARRINHO ATIVO SE NÃO ESTIVER EDITANDO
    if (_editingPurchase == null) {
      _cartService.saveCart(_cartItems);
    }
    _calculateTotal();
  }


  void _removeItem(int index) async {
    setState(() {
      _cartItems.removeAt(index);
    });
    // SÓ SALVA NO CARRINHO ATIVO SE NÃO ESTIVER EDITANDO
    if (_editingPurchase == null) {
      await _cartService.saveCart(_cartItems);
    }
    _calculateTotal();
  }

  Future<void> _showEditBudgetDialog() async {
    final TextEditingController budgetController = TextEditingController(text: _budget > 0 ? _budget.toStringAsFixed(2) : '');
    final newBudget = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Orçamento'),
        content: TextField(
          controller: budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: 'Ex: 400.00',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(budgetController.text.replaceAll(',', '.')) ?? 0.0;
              Navigator.pop(context, value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newBudget != null) {
      await _cartService.saveBudget(newBudget);
      setState(() { _budget = newBudget; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _cartItems.isEmpty
                        ? const Center(child: Text('Seu carrinho está vazio.'))
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return CartItemCard(
                                  name: item.name,
                                  quantity: item.quantity,
                                  price: item.price,
                                  onDecrement: () {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                      _updateItem(index, item);
                                    } else {
                                      _removeItem(index);
                                    }
                                  },
                                  onIncrement: () {
                                    item.quantity++;
                                    _updateItem(index, item);
                                  },
                                  onPriceChanged: (newPrice) {
                                    item.price = newPrice;
                                    _updateItem(index, item);
                                  },
                                );
                              },
                            ),
                        ),
                  ),
                  _buildFooter(),
                ],
              ),
      ),
    );
  }

  // --- NOVA FUNÇÃO PARA CHAMAR O DIÁLOGO E ADICIONAR O ITEM ---
void _quickAddItem() async {
    final newItem = await _showQuickAddDialog();
    if (newItem != null) {
      setState(() {
        _cartItems.add(newItem);
        _calculateTotal();
      });
      // SÓ SALVA NO CARRINHO ATIVO SE NÃO ESTIVER EDITANDO
      if (_editingPurchase == null) {
        await _cartService.saveCart(_cartItems);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newItem.name} adicionado ao carrinho!')),
      );
    }
  }
  // --- NOVO DIÁLOGO PARA ADIÇÃO RÁPIDA ---
  Future<ShoppingListItem?> _showQuickAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    return showDialog<ShoppingListItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Item Rápido'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                    labelText: 'Preço (unidade)', prefixText: 'R\$ '),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Insira uma quantidade válida.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = ShoppingListItem(
                  name: nameController.text.trim(),
                  price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                  quantity: int.parse(quantityController.text),
                );
                Navigator.pop(context, newItem);
              }
            },
            child: const Text('Adicionar'),
          )
        ],
      ),
    );
  }

 Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: Row(
        children: [
          // Botão de voltar (existente)
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
          // Título
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _editingPurchase != null ? Colors.orange.shade300 : const Color(0xFF82C8A0), // Muda de cor em modo de edição
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _editingPurchase != null ? 'MODO EDIÇÃO' : 'CARRINHO',
                  style: GoogleFonts.bungee(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
          // Se estiver em modo de edição, mostra o botão de cancelar
          if (_editingPurchase != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 30),
              onPressed: _cancelEditing,
              tooltip: 'Cancelar Edição',
            )
          else // Senão, mostra os botões normais
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 30),
                  onPressed: _clearCart,
                  tooltip: 'Limpar Carrinho',
                ),
                IconButton(
                  icon: const Icon(Icons.history_edu_outlined, size: 30),
                  onPressed: _navigateToHistory,
                  tooltip: 'Histórico de Compras',
                ),
              ],
            )
        ],
      ),
    );
  }
  Future<void> _navigateToHistory() async {
    final selectedPurchase = await Navigator.push<PurchaseHistory>(
      context, MaterialPageRoute(builder: (_) => const HistoryScreen()));

    if (selectedPurchase != null) {
      // Guarda o estado atual do carrinho para poder cancelar depois
      _cartBeforeEdit = List.from(_cartItems);

      // Entra no modo de edição
      setState(() {
        _editingPurchase = selectedPurchase;
        _cartItems = selectedPurchase.items; // Carrega os itens da compra selecionada
        _calculateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modo de Edição: Editando "${selectedPurchase.supermarketName}"')),
      );
    }
  }
void _cancelEditing() {
    setState(() {
      _editingPurchase = null;
      _cartItems = _cartBeforeEdit; // 1. Restaura o carrinho
      _cartBeforeEdit = [];         // 2. LIMPA O BACKUP
      _calculateTotal();            // 3. Recalcula o total
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edição cancelada.')),
    );
  }

  void _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Carrinho?'),
        content: const Text('Todos os itens serão removidos. Deseja continuar?'),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text('Não')),
          ElevatedButton(onPressed: ()=> Navigator.pop(context, true), child: const Text('Sim')),
        ],
      )
    );

    if (confirm == true) {
      await _cartService.clearCart();
      await _loadData();
    }
  }

 
  Future<bool?> _showConfirmReplaceDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Substituir Carrinho?'),
        content: const Text(
            'Seu carrinho atual não está vazio. Deseja limpá-lo e carregar os itens da compra antiga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, substituir'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final progress = (_budget > 0 && _total > 0) ? (_total / _budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORÇAMENTO', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('R\$${_budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: progress > 0.85 ? Colors.red : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Botão Editar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEditBudgetDialog,
                ),
              ),
              const SizedBox(width: 8),
              // Botão Histórico (sem funcionalidade ainda)
              Container(
                 decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: IconButton(
                  icon: const Icon(Icons.playlist_add), // Ícone alterado
                  onPressed: _quickAddItem, // Chama a nova função
                  tooltip: 'Adicionar Item Rápido',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ElevatedButton(
            onPressed: _saveOrCompletePurchase, // Chama a nova função unificada
            child: Text(
              // Muda o texto do botão de acordo com o modo
              _editingPurchase != null
                  ? 'SALVAR EDIÇÃO'
                  : 'TOTAL: R\$${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
          ),
        ],
      ),
    );
  }
}