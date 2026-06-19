import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/pages/currency_converter_page.dart';
import 'package:animations_in_flutter/views/pages/favorites_page.dart';
import 'package:animations_in_flutter/views/pages/memory_page.dart';
import 'package:animations_in_flutter/views/widgets/home/title_widget.dart';
import 'package:animations_in_flutter/views/widgets/home/trip_list_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final c = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.28,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    height: size.height * 0.32,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      builder: (_, v, ch) => Opacity(opacity: v, child: ch),
                      child: Image.asset(
                        'assets/images/bg.png',
                        semanticLabel: l10n.appBannerSemantics,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: size.width * 0.03,
                    bottom: 65,
                    child: Padding(
                      padding: EdgeInsets.only(top: size.height * 0.04),
                      child: titleWidget(l10n.appTitle, context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CurrencyConverterPage(),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(l10n.currencyConverter),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemoryPage()),
                    ),
                    icon: const Icon(Icons.timeline_rounded, size: 18),
                    label: Text(l10n.memories),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    ),
                    icon: const Icon(Icons.favorite_outline_rounded),
                    tooltip: l10n.favorites,
                  ),
                ],
              ),
            ),
            Expanded(child: const TripListWidget()),
          ],
        ),
      ),
    );
  }
}
