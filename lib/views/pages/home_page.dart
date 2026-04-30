import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/title_widget.dart';
import 'package:animations_in_flutter/views/widgets/trip_list_widget.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER SECTION (STACK UNCHANGED AS REQUESTED) ---
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            height: 300,
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 400),
                              builder: (context, value, child) =>
                                  Opacity(opacity: value, child: child),
                              child: Image.asset(
                                "images/bg.png",
                                semanticLabel: 'Banner of the app',
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            bottom: 65,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: size.width * 0.03,
                                top: size.height * 0.04,
                              ),
                              child: titleWidget(
                                AppLocalizations.of(context)!.appTitle,
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- THE LIST "SHEET" SECTION ---
            Expanded(child: const TripListPage()),
            SizedBox(height: size.height * 0.08),
          ],
        ),
      ),
    );
  }
}
