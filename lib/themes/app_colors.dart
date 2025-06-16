import 'package:flutter/material.dart';

class AppColors {
  // **🌞 Modo Claro (Light Mode)**
  static const Color primary = Color(0xFF1E3A5F);          // Azul Profundo
  static const Color secondary = Color(0xFF345A74);        // Azul Médio
  static const Color accent = Color(0xFF90A4AE);           // Azul Pastel Suave

  // **Fundos e Superfícies**
  static const Color background = Color(0xFFFFFFFF);       // Branco para melhor contraste
  static const Color surface = Color(0xFFF8F9FA);          // Cinza ultra claro para cartões

  // **Texto**
  static const Color textPrimary = Color(0xFF212121);      // Preto Suave para melhor legibilidade
  static const Color textSecondary = Color(0xFF9E9E9E); // Cinza bem suave
  static const Color textHint = Color(0xFF757575);         // Cinza Médio para placeholders

  // **Bordas e Divisórias**
  static const Color border = Color(0xFFE0E0E0);           // Cinza Claro para separações

  // **Estados de Feedback**
  static const Color success = Color(0xFF388E3C);          // Verde para Sucesso
  static const Color warning = Color(0xFFFB8C00);          // Amarelo para Avisos
  static const Color error = Color(0xFFD32F2F);            // Vermelho para Erros
  static const Color info = Color(0xFF42A5F5);

  // **Botões**
  static const Color buttonPrimary = primary;              // Azul Profundo para Botões Principais
  static const Color buttonSecondary = secondary;          // Azul Médio para Botões Secundários
  static const Color buttonText = Color(0xFFFFFFFF);       // Branco para Texto de Botões

  // **Campos de Texto**
  static const Color textField = surface;                  // Fundo Claro para Campos de Texto
  static const Color textFieldBorder = border;             // Borda Cinza Claro

  // **Cartões**
  static const Color cardBackground = surface;             // Fundo Claro para Cartões

  // **🌙 Modo Escuro (Dark Mode)**
  static const Color darkBackground = Color(0xFF121212);   // Preto Suave (Material You)
  static const Color darkSurface = Color(0xFF1E1E1E);      // Cinza Muito Escuro

  // **Texto no Modo Escuro**
  static const Color textOnDark = Color(0xFFE0E0E0);       // Cinza Claro para melhor leitura

  // **Bordas no Modo Escuro**
  static const Color darkBorder = Color(0xFF424242);       // Cinza Médio

  // **Cartões no Modo Escuro**
  static const Color darkCardBackground = darkSurface;     // Fundo para Cartões no Dark Mode

  // **Gradientes**
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}