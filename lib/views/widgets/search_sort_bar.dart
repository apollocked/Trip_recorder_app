import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/settings_modal.dart';

class SearchSortBar extends StatefulWidget {
  const SearchSortBar({super.key});

  @override
  State<SearchSortBar> createState() => _SearchSortBarState();
}

class _SearchSortBarState extends State<SearchSortBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (_searchController.text != provider.searchQuery) {
          _searchController.text = provider.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchTrips,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => provider.setSearchQuery(val),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(colorScheme, l10n, null, provider.categoryFilter == null, () => provider.setCategoryFilter(null)),
                          ...TripCategory.values.map((cat) => _buildFilterChip(
                            colorScheme, l10n, cat, provider.categoryFilter == cat, () => provider.setCategoryFilter(cat),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort_rounded, size: 22),
                    tooltip: l10n.sortLabel,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (val) => provider.setSortBy(val),
                    itemBuilder: (_) => [
                      _sortItem(l10n.newest, 'date_desc', provider.sortBy),
                      _sortItem(l10n.oldest, 'date_asc', provider.sortBy),
                      _sortItem(l10n.priceAsc, 'price_asc', provider.sortBy),
                      _sortItem(l10n.priceDesc, 'price_desc', provider.sortBy),
                      _sortItem(l10n.ratingLabel, 'rating_desc', provider.sortBy),
                      _sortItem(l10n.az, 'title_asc', provider.sortBy),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    tooltip: l10n.settingsTitle,
                    onPressed: () => showSettingsModal(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(ColorScheme colorScheme, var l10n, TripCategory? cat, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(cat == null ? l10n.all : cat.label, style: TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  PopupMenuItem<String> _sortItem(String label, String value, String current) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(current == value ? Icons.check_rounded : null, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
