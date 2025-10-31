// lib/main.dart
import 'package:flutter/material.dart';
import 'package:compracerta/screens/price_comparison_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Usamos um tema base do Flutter para obter o textTheme inicial.
    // Não podemos usar 'Theme.of(context)' aqui porque o tema ainda não foi criado.
    final baseTheme = ThemeData.light();
    final baseTextTheme = baseTheme.textTheme;

    return MaterialApp(
      title: 'Comparador de Preços',
      home: PriceComparisonScreen(),
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith( // Usamos .copyWith() para modificar o tema base
        // 1. APLICAR DM SANS COMO FONTE BASE PARA TUDO
        textTheme: GoogleFonts.dmSansTextTheme(baseTextTheme).copyWith(
          // 2. SOBRESCREVER OS ESTILOS DE TÍTULO/DESTAQUE COM BUNGEE
          displayLarge: GoogleFonts.bungee(textStyle: baseTextTheme.displayLarge),
          displayMedium: GoogleFonts.bungee(textStyle: baseTextTheme.displayMedium),
          displaySmall: GoogleFonts.bungee(textStyle: baseTextTheme.displaySmall),
          headlineLarge: GoogleFonts.bungee(textStyle: baseTextTheme.headlineLarge),
          headlineMedium: GoogleFonts.bungee(textStyle: baseTextTheme.headlineMedium),
          headlineSmall: GoogleFonts.bungee(textStyle: baseTextTheme.headlineSmall),
        ),
      ),
    );
  }
}