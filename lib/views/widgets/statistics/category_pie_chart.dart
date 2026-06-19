import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final Map categoryCounts;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const CategoryPieChart({
    super.key,
    required this.categoryCounts,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  static const _categoryColors = AppColors.chartPalette;

  @override
  Widget build(BuildContext context) {
    final entries = widget.categoryCounts.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + (e.value as int));
    if (total == 0) return const SizedBox.shrink();

    final sections = entries.asMap().entries.map((e) {
      final isTouched = e.key == _touchedIndex;
      return PieChartSectionData(
        color: _categoryColors[e.key % _categoryColors.length],
        value: (e.value.value as int).toDouble(),
        title: isTouched ? (e.value.key as TripCategory).label(widget.l10n) : '${e.value.value}',
        radius: isTouched ? 58 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 13,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 45,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _touchedIndex == -1 ? '$total' : '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _touchedIndex == -1 ? widget.l10n.totalLabel : '',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
