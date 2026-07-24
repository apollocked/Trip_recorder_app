import 'dart:convert';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';

class CloudTripRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<Trip>> getAllTrips() async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_trips')
        .select()
        .eq('user_id', _svc.userId!)
        .order('created_at', ascending: false);
    return (data as List).map((map) => _fromCloudMap(map)).toList();
  }

  Future<Trip> insertTrip(Trip trip) async {
    await _svc.client.from('cloud_trips').insert(_toCloudMap(trip));
    return trip;
  }

  Future<void> updateTrip(Trip trip) async {
    await _svc.client
        .from('cloud_trips')
        .update(_toCloudMap(trip))
        .eq('id', trip.id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteTrip(String id) async {
    await _svc.client
        .from('cloud_trips')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> toggleLike(String id) async {
    await _svc.client.rpc('toggle_trip_like', params: {'trip_id_param': id});
  }

  Future<void> insertAll(List<Trip> trips) async {
    if (trips.isEmpty || !_svc.isLoggedIn) return;
    final batch = trips.map((t) => _toCloudMap(t)).toList();
    await _svc.client.from('cloud_trips').upsert(batch);
  }

  Map<String, dynamic> _toCloudMap(Trip trip) => {
        'id': trip.id,
        'user_id': _svc.userId,
        'title': trip.title,
        'price': trip.price,
        'nights': trip.nights,
        'image_paths': trip.imagePaths,
        'date': trip.date.toIso8601String(),
        'description': trip.description,
        'is_liked': trip.isLiked,
        'created_at': trip.createdAt.toIso8601String(),
        'category': trip.category.name,
        'rating': trip.rating,
        'currency': trip.currency,
        'reminder_date': trip.reminderDate?.toIso8601String(),
      };

  Trip _fromCloudMap(Map<String, dynamic> map) {
    List<String> paths = [];
    final raw = map['image_paths'];
    if (raw is List) {
      paths = raw.cast<String>();
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) paths = decoded.cast<String>();
      } catch (_) {}
    }
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      nights: (map['nights'] as num).toInt(),
      imagePaths: paths,
      date: DateTime.parse(map['date'] as String),
      description: (map['description'] as String?) ?? '',
      isLiked: (map['is_liked'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      category: TripCategory.fromString((map['category'] as String?) ?? 'other'),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      currency: (map['currency'] as String?) ?? 'USD',
      reminderDate: map['reminder_date'] != null
          ? DateTime.parse(map['reminder_date'] as String)
          : null,
    );
  }
}
