import 'package:flutter/material.dart';

class InfoRowData {
  const InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;
}
