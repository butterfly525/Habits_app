import 'package:flutter/material.dart';

class HabitColorOption {
  const HabitColorOption({
    required this.value,
    required this.name,
  });

  final int value;
  final String name;
}

const habitColorOptions = <HabitColorOption>[
  HabitColorOption(value: 0xFF2E7D32, name: 'Зеленый'),
  HabitColorOption(value: 0xFF1565C0, name: 'Синий'),
  HabitColorOption(value: 0xFFF57C00, name: 'Оранжевый'),
  HabitColorOption(value: 0xFFC2185B, name: 'Розовый'),
  HabitColorOption(value: 0xFF6A1B9A, name: 'Фиолетовый'),
  HabitColorOption(value: 0xFF455A64, name: 'Графит'),
];

Color habitColorFromValue(int value) => Color(value);
