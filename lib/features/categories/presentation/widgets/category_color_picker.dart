import 'package:flutter/material.dart';

Color categoryColor(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
    return const Color(0xFF825B42);
  }
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}

class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String? value;
  final ValueChanged<String?>? onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final color in <String?>[
        null,
        '#825B42',
        '#C48763',
        '#66806A',
        '#65869A',
        '#9275A0',
        '#C59A43',
        '#B76970',
      ])
        Semantics(
          selected: value == color,
          child: IconButton.filledTonal(
            tooltip: color == null ? 'Tanpa warna' : 'Warna $color',
            style: IconButton.styleFrom(
              backgroundColor: color == null
                  ? Colors.grey.shade200
                  : categoryColor(color),
              foregroundColor: color == null ? Colors.black54 : Colors.white,
            ),
            onPressed: onChanged == null ? null : () => onChanged!(color),
            icon: Icon(
              value == color
                  ? Icons.check
                  : color == null
                  ? Icons.block
                  : Icons.circle,
              size: 22,
            ),
          ),
        ),
    ],
  );
}
