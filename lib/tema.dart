import 'package:flutter/material.dart';

/// Paleta tomada del diseño de Figma.
class C {
  static const bg = Color(0xFF141414);
  static const card = Color(0xFF232420);
  static const borde = Color(0xFF34352F);
  static const oro = Color(0xFFDBAF6B);
  static const oroSuave = Color(0xFF3A3021);
  static const texto = Color(0xFFF5F0E6);
  static const gris = Color(0xFF9A978F);
  static const verde = Color(0xFF8FC79A);
  static const verdeFondo = Color(0xFF26372B);
  static const rojo = Color(0xFFE07A6E);
  static const rojoFondo = Color(0xFF3A2422);
  static const oscuro = Color(0xFF1A1A1A);
}

OutlineInputBorder _borde(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c),
    );

ThemeData get temaApp => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(
        primary: C.oro,
        onPrimary: C.oscuro,
        surface: C.card,
        onSurface: C.texto,
        error: C.rojo,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: C.oro,
        selectionHandleColor: C.oro,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: C.card,
        labelStyle: const TextStyle(color: C.gris),
        hintStyle: const TextStyle(color: C.gris),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _borde(C.borde),
        enabledBorder: _borde(C.borde),
        focusedBorder: _borde(C.oro),
        errorBorder: _borde(C.rojo),
        focusedErrorBorder: _borde(C.rojo),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.card,
        contentTextStyle: TextStyle(color: C.texto),
      ),
    );

// ---------------------------------------------------------------------------
// Utilidades de fecha y texto (en español, sin depender de intl)
// ---------------------------------------------------------------------------
const _dias = [
  'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
  'septiembre', 'octubre', 'noviembre', 'diciembre'
];

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String nombreDia(DateTime d) => _dias[d.weekday - 1];
String nombreMes(DateTime d) => _meses[d.month - 1];
String mesCorto(DateTime d) => _meses[d.month - 1].substring(0, 3);
String fechaLarga(DateTime d) =>
    '${cap(nombreDia(d))}, ${d.day} de ${nombreMes(d)} de ${d.year}';
String horaTxt(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String dinero(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '\$$b';
}

DateTime soloDia(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime sumarDias(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String iniciales(String nombre) {
  final p = nombre.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  if (p.length == 1) return p[0][0].toUpperCase();
  return (p[0][0] + p[1][0]).toUpperCase();
}

String sinAcentos(String s) {
  const a = 'áéíóúüñ';
  const b = 'aeiouun';
  var r = s.toLowerCase();
  for (var i = 0; i < a.length; i++) {
    r = r.replaceAll(a[i], b[i]);
  }
  return r;
}

String etiquetaDia(DateTime d) {
  final hoy = soloDia(DateTime.now());
  if (mismoDia(d, hoy)) return 'Hoy, ${nombreDia(d)} ${d.day}';
  if (mismoDia(d, sumarDias(hoy, 1))) return 'Mañana, ${nombreDia(d)} ${d.day}';
  if (mismoDia(d, sumarDias(hoy, -1))) return 'Ayer, ${nombreDia(d)} ${d.day}';
  return '${cap(nombreDia(d))} ${d.day} de ${nombreMes(d)}';
}
