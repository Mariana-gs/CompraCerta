// lib/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

// Widget principal da barra de navegação
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Aumentamos a altura para dar mais espaço
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Fundo da Barra de Navegação (a parte branca)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                /*boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],*/
              ),
            ),
          ),

          // 2. Linha com os três botões flutuantes
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NavButton(
                  imagePath: 'assets/images/list_icon.png', // <-- SUA IMAGEM AQUI
                  unselectedColor: const Color(0xFFF99162),
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemTapped(0),
                ),
                _NavButton(
                  imagePath: 'assets/images/balance_icon.png',
                  unselectedColor: const Color(0xFFFFDE6E),
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemTapped(1),
                ),
                _NavButton(
                  imagePath: 'assets/images/cart_icon.png', // <-- SUA IMAGEM AQUI
                  unselectedColor: const Color(0xFF5FAD8D),
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemTapped(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget interno e reutilizável para cada botão da barra de navegação
class _NavButton extends StatelessWidget {
  final String imagePath;
  final Color unselectedColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.imagePath,
    required this.unselectedColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFFFFDE6E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: Colors.black, width: 4) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 28.0,
            height: 28.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}