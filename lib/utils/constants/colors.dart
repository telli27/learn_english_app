import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF4F6CFF); // Modern, koyu mavi tonu
  static const Color secondary = Color(0xFF536DFE); // Parlak mavi
  static const Color tertiary = Color(0xFF00BFA5); // Yeşil aksan rengi

  // Koyu tema ana renkleri
  static const Color primaryDark =
      Color(0xFF3D5CFF); // Koyu tema için daha koyu mavi
  static const Color secondaryDark = Color(0xFF3D5AF0); // Koyu tema parlak mavi
  static const Color tertiaryDark = Color(0xFF00A896); // Koyu tema yeşil aksan

  // Nötr renkler
  static const Color background = Color(0xFFF7F8FC); // Açık arka plan
  static const Color surface = Color(0xFFFFFFFF); // Yüzey rengi
  static const Color surfaceLight = Color(0xFFF9FAFC); // Daha açık yüzey rengi
  static const Color divider = Color(0xFFEAECF0); // Bölücü rengi

  // Metin renkleri
  static const Color textPrimary = Color(0xFF1D2939); // Ana metin rengi
  static const Color textSecondary = Color(0xFF667085); // İkincil metin rengi
  static const Color textLight = Color(0xFF98A2B3); // Açık metin rengi

  // Durum renkleri
  static const Color success = Color(0xFF34C759); // Başarı rengi
  static const Color warning = Color(0xFFFF9500); // Uyarı rengi
  static const Color error = Color(0xFFFF3B30); // Hata rengi
  static const Color info = Color(0xFF5AC8FA); // Bilgi rengi

  // Renk tonları - tüm uygulamada tutarlı bir görünüm için
  static Map<String, Color> colorTones = {
    'blue': const Color(0xFF4F6CFF),
    'purple': const Color(0xFF7B61FF),
    'green': const Color(0xFF00BFA5),
    'orange': const Color(0xFFFF9500),
    'red': const Color(0xFFFF3B30),
    'teal': const Color(0xFF5AC8FA),
    'pink': const Color(0xFFFF375F),
    'yellow': const Color(0xFFFFCC00),
  };

  // String hex rengini Color'a dönüştürme
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Renk tonu alma yardımcısı
  static Color getColorByName(String name) {
    return colorTones[name.toLowerCase()] ?? primary;
  }
}
