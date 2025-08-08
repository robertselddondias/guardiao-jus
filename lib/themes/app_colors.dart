import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // **🌞 LIGHT MODE - Cores Modernas e Elegantes**
  static const Color lightPrimary = Color(0xFF0F4C75);         // Azul Naval Profundo
  static const Color lightSecondary = Color(0xFF3282B8);       // Azul Oceano Vibrante
  static const Color lightTertiary = Color(0xFF00B4D8);        // Azul Cyan Moderno

  // **Cores de Superfície Light - Inspiradas no Material You**
  static const Color lightBackground = Color(0xFFFCFCFF);      // Branco Ultra Suave
  static const Color lightSurface = Color(0xFFFFFFFF);         // Branco Puro para Cards
  static const Color lightSurfaceVariant = Color(0xFFF6F8FC);  // Azul Gelo Sutil

  // **Texto Light - Contraste Otimizado**
  static const Color lightOnBackground = Color(0xFF1A1B1E);    // Preto Suave
  static const Color lightOnSurface = Color(0xFF1A1B1E);       // Preto Suave
  static const Color lightOnPrimary = Color(0xFFFFFFFF);       // Branco
  static const Color lightOnSecondary = Color(0xFFFFFFFF);     // Branco

  // **Cores de Estado Light**
  static const Color lightSuccess = Color(0xFF16A085);         // Verde Esmeralda
  static const Color lightWarning = Color(0xFFE67E22);         // Laranja Vivo
  static const Color lightError = Color(0xFFE74C3C);           // Vermelho Coral
  static const Color lightInfo = Color(0xFF3498DB);            // Azul Info

  // **Bordas e Outlines Light**
  static const Color lightOutline = Color(0xFFE8ECF4);         // Cinza Azulado Claro
  static const Color lightOutlineVariant = Color(0xFFF0F3F7);  // Cinza Muito Claro

  // **🌙 DARK MODE - Elegante e Sofisticado**
  static const Color darkPrimary = Color(0xFF5DADE2);          // Azul Claro Vibrante
  static const Color darkSecondary = Color(0xFF85C1E9);        // Azul Pastel Suave
  static const Color darkTertiary = Color(0xFF48CAE4);         // Cyan Luminoso

  // **Cores de Superfície Dark - Material You 3.0**
  static const Color darkBackground = Color(0xFF0A0E13);       // Preto Azulado Profundo
  static const Color darkSurface = Color(0xFF1A1E24);          // Cinza Azulado Escuro
  static const Color darkSurfaceVariant = Color(0xFF242933);   // Cinza Médio Azulado

  // **Texto Dark - Legibilidade Premium**
  static const Color darkOnBackground = Color(0xFFE8EAED);     // Branco Suave
  static const Color darkOnSurface = Color(0xFFE8EAED);        // Branco Suave
  static const Color darkOnPrimary = Color(0xFF0A0E13);        // Preto Azulado
  static const Color darkOnSecondary = Color(0xFF0A0E13);      // Preto Azulado

  // **Cores de Estado Dark**
  static const Color darkSuccess = Color(0xFF52C41A);          // Verde Neon Suave
  static const Color darkWarning = Color(0xFFFFA940);          // Laranja Dourado
  static const Color darkError = Color(0xFFFF4D4F);            // Vermelho Neon
  static const Color darkInfo = Color(0xFF40A9FF);             // Azul Elétrico

  // **Bordas e Outlines Dark**
  static const Color darkOutline = Color(0xFF3C4043);          // Cinza Médio
  static const Color darkOutlineVariant = Color(0xFF2A2E33);   // Cinza Escuro

  // **Cores Especiais para Glassmorphism**
  static const Color glassLight = Color(0x1AFFFFFF);           // Branco Translúcido
  static const Color glassDark = Color(0x1A000000);            // Preto Translúcido

  // **Gradientes Modernos**
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [lightPrimary, lightSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [darkPrimary, darkSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // **Sombras Elegantes**
  static List<BoxShadow> lightElevation1 = [
    BoxShadow(
      color: lightPrimary.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkElevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: darkPrimary.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}