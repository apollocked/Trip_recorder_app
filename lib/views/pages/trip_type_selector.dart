import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/route_transition.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';

class TripTypeSelector extends StatefulWidget {
  const TripTypeSelector({super.key});

  @override
  State<TripTypeSelector> createState() => _TripTypeSelectorState();
}

class _TripTypeSelectorState extends State<TripTypeSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.newjourney,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
                  child: Text(
                    l10n.howToStart,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _OptionCard(
                        icon: Icons.photo_camera_rounded,
                        label: l10n.recordMemory,
                        gradientColors: [
                          cs.secondaryContainer,
                          cs.tertiaryContainer.withAlpha(180),
                        ],
                        iconColor: cs.onSecondaryContainer,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          slideRoute(AddTripPage(isFutureTrip: false)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _OptionCard(
                        icon: Icons.flight_takeoff_rounded,
                        label: l10n.planTrip,
                        gradientColors: [
                          cs.primaryContainer,
                          cs.secondaryContainer.withAlpha(200),
                        ],
                        iconColor: cs.onPrimaryContainer,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          slideRoute(AddTripPage(isFutureTrip: true)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DescriptionList(
                          items: [
                            _DescItem(Icons.add_photo_alternate_rounded, l10n.photos),
                            _DescItem(Icons.star_rounded, l10n.rateTrip),
                            _DescItem(Icons.category_rounded, l10n.tripCategory),
                          ],
                          color: cs.onSurfaceVariant,
                          tt: tt,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DescriptionList(
                          items: [
                            _DescItem(Icons.notifications_active_rounded, l10n.reminders),
                            _DescItem(Icons.checklist_rounded, l10n.packingList),
                            _DescItem(Icons.flight_rounded, l10n.countdown),
                          ],
                          color: cs.onSurfaceVariant,
                          tt: tt,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DescItem {
  final IconData icon;
  final String label;
  const _DescItem(this.icon, this.label);
}

class _DescriptionList extends StatelessWidget {
  final List<_DescItem> items;
  final Color color;
  final TextTheme tt;

  const _DescriptionList({
    required this.items,
    required this.color,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in items) ...[
          Row(
            children: [
              Icon(d.icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  d.label,
                  style: tt.bodySmall?.copyWith(color: color, height: 1.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _OptionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _hover, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, _) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => _hover.forward(),
          onTapUp: (_) => _hover.reverse(),
          onTapCancel: () => _hover.reverse(),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 22, color: widget.iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.iconColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
