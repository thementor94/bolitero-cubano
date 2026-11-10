import 'package:flutter/material.dart';

abstract final class AppColors {
  // Nivel de superficies (tonalidad oscura sin sombras pesadas, optimizada para pantallas OLED)
  static const canvas    = Color(0xFF0E1116); // Nivel 0: fondo de app
  static const card      = Color(0xFF171B22); // Nivel 1: tarjetas y contenedores
  static const border    = Color(0xFF262B35); // Borde arquitectónico de 1px
  static const sheet     = Color(0xFF1E232C); // Nivel 2: modales y hojas inferiores
  static const sheetEdge = Color(0xFF363D4A); // Borde de modales
  static const key       = Color(0xFF252B36); // Nivel 3: teclas del teclado 3x4

  // Acentos funcionales de la Bolita
  static const gold        = Color(0xFFF2B33D); // Fijo, acción principal y activo
  static const goldPressed = Color(0xFFD49B2F); // Estado presionado
  static const turquoise   = Color(0xFF2EC4B6); // Corridos y estado oficial en vivo
  static const hot         = Color(0xFFFF9F1C); // Números calientes
  static const cold        = Color(0xFFFF5C5C); // Números atrasados (fríos) y alertas
  static const ok          = Color(0xFF38B000); // Estado sincronizado / en caché local

  // Jerarquía tipográfica de texto
  static const text      = Color(0xFFF5F7FA); // Blanco nítido de lectura
  static const textMuted = Color(0xFF9AA3B2); // Gris secundario / metadatos
  static const textFaint = Color(0xFF6C7689); // Divisores y marcas menores
}
