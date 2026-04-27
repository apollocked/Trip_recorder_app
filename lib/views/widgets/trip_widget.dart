import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/data/trip_list.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:flutter/material.dart';

class TripWidget extends StatelessWidget {
  const TripWidget({super.key, required this.trip});

  final List<Trip> trip;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(trip: trip[index]),
              ),
            );
          },
          contentPadding: EdgeInsets.all(25),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${trip[index].nights} nights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[300],
                ),
              ),
              Text(
                trip[index].title,
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            ],
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset('images/${trip[index].img}', height: 50.0),
          ),
          trailing: Text('\$${trip[index].price}'),
        );
      },
    );
  }
}
