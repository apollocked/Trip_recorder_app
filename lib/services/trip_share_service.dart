import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:animations_in_flutter/model/trip.dart';

class TripShareService {
  static Future<void> shareTrip(Trip trip, {Rect? sharePositionOrigin}) async {
    final buffer = StringBuffer();
    buffer.writeln('=== ${trip.title} ===');
    buffer.writeln('Date: ${trip.date.day}/${trip.date.month}/${trip.date.year}');
    buffer.writeln('Nights: ${trip.nights}');
    buffer.writeln('Category: ${trip.category.name}');
    buffer.writeln('Price: ${trip.price.toStringAsFixed(0)} ${trip.currency}');
    if (trip.rating > 0) buffer.writeln('Rating: ${trip.rating.toStringAsFixed(1)}/5');
    if (trip.description.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(trip.description);
    }
    buffer.writeln();
    buffer.writeln('Shared from Trip Recorder');
    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        sharePositionOrigin: sharePositionOrigin ??
            const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }
}
