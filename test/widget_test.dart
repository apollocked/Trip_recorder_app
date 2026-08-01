import 'package:flutter_test/flutter_test.dart';

import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/services/premium_service.dart';

void main() {
  group('PremiumService free-tier limits', () {
    final service = PremiumService();

    test('free users can add trips up to freeMaxTrips', () {
      for (var count = 0; count < AppConstants.freeMaxTrips; count++) {
        expect(service.canAddTripWithCount(count), isTrue,
            reason: 'should allow trip #${count + 1}');
      }
      expect(
        service.canAddTripWithCount(AppConstants.freeMaxTrips),
        isFalse,
        reason: 'should block when at the free trip limit',
      );
      expect(service.canAddTripWithCount(50), isFalse);
    });

    test('free users can add photos up to freeMaxPhotosPerTrip', () {
      for (var count = 0; count < AppConstants.freeMaxPhotosPerTrip; count++) {
        expect(service.canAddPhotos(count), isTrue,
            reason: 'should allow photo #${count + 1}');
      }
      expect(
        service.canAddPhotos(AppConstants.freeMaxPhotosPerTrip),
        isFalse,
        reason: 'should block when at the free photo limit',
      );
    });

    test('free users cannot add custom categories', () {
      expect(service.canAddCustomCategory, isFalse);
    });

    test('remainingTripsMessage reports remaining and full states', () {
      final remainingMsg = service.remainingTripsMessage(2);
      expect(
        remainingMsg,
        contains('${AppConstants.freeMaxTrips - 2}'),
        reason: 'should mention remaining trips',
      );

      final fullMsg = service.remainingTripsMessage(AppConstants.freeMaxTrips);
      expect(fullMsg, contains('${AppConstants.freeMaxTrips}'),
          reason: 'should mention the free trip limit');
    });
  });
}
