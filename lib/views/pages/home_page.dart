// ignore_for_file: use_build_context_synchronously

import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/title_widget.dart';
import 'package:animations_in_flutter/views/widgets/trip_list_widget.dart'; // Ensure this matches your class name
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                              child: Image.asset("images/bg.png"),
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
                              child: titleWidget("Trip /nRecorder", context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TripListPage(), // Your animated list widget
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newTrip = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTripPage()),
          );
          if (newTrip != null && mounted) {
            // Use Provider to save it permanently and update the list
            Provider.of<TripService>(context, listen: false).addTrip(newTrip);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 4,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          "New Trip",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
