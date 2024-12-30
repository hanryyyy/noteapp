import 'package:flutter/material.dart';

class NoteColorAssigner {
  static const List<Color> _colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
  ];

  static int getColorIndex(String noteId) {
    final int hash = noteId.hashCode;
    return hash % _colors.length;
  }

  static Color getColorFromIndex(int index) {
    return _colors[index];
  }

  static List<Color> get colors => _colors;
}
