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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topLeft,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: size.height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget("Flutter Animations"),
              SizedBox(height: 35),
              Expanded(child: TripListPage()),
            ],
          ),
        ),
      ),
    );
  }
}
