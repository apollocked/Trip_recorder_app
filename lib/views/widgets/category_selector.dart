import 'package:flutter/material.dart';
import 'package:animations_in_flutter/model/trip_category.dart';

class CategorySelector extends StatelessWidget {
  final TripCategory selectedCategory;
  final ValueChanged<TripCategory> onChanged;
  final ColorScheme colorScheme;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: TripCategory.values.map((cat) {
        final isSelected = selectedCategory == cat;
        return ChoiceChip(
          label: Text(cat.label),
          selected: isSelected,
          selectedColor: colorScheme.primaryContainer,
          onSelected: (selected) { if (selected) onChanged(cat); },
        );
      }).toList(),
    );
  }
}
