import 'package:flutter_test/flutter_test.dart';
import 'package:saarthi_mobile/data/local_repository.dart';
import 'package:saarthi_mobile/core/constants.dart';

void main() {
  group('Distance Engine Verification', () {
    test('Case 4: Plains to Plains - Tirupati Station to Alipiri Foot', () {
      final dist = LocalRepository.calculateDrivingDistance(
        AppConstants.tirupatiStationLat,
        AppConstants.tirupatiStationLng,
        AppConstants.alipiriLat,
        AppConstants.alipiriLng,
        isTirumalaDestination: false,
      );

      // Driving distance from Tirupati Station to Alipiri via city roads is ~2.8 - 4.5 km
      expect(dist, greaterThan(2.5));
      expect(dist, lessThan(5.0));
    });

    test('Case 2: Plains to Hill - Tirupati Station to Tirumala Srivari Temple', () {
      final dist = LocalRepository.calculateDrivingDistance(
        AppConstants.tirupatiStationLat,
        AppConstants.tirupatiStationLng,
        AppConstants.tirumalaLat,
        AppConstants.tirumalaLng,
        isTirumalaDestination: true,
      );

      // Distance from Tirupati Station to Tirumala temple via 18.5 km Up-Ghat road is approx 21 - 26 km
      expect(dist, greaterThan(20.0));
      expect(dist, lessThan(28.0));
    });

    test('Case 1: Hill to Hill - Within Tirumala plateau (No Ghat climb applied)', () {
      // From Tirumala Center (13.6833, 79.3473) to Japali Hanuman (13.702, 79.336)
      final dist = LocalRepository.calculateDrivingDistance(
        AppConstants.tirumalaLat,
        AppConstants.tirumalaLng,
        13.702,
        79.336,
        isTirumalaDestination: true,
      );

      // Hill-to-hill distance should be ~2.5 - 5.5 km, NOT adding the 18.5 km Ghat climb
      expect(dist, greaterThan(1.0));
      expect(dist, lessThan(8.0));
    });

    test('Case 3: Hill to Plains - Tirumala Temple down to Tirupati Station', () {
      final dist = LocalRepository.calculateDrivingDistance(
        AppConstants.tirumalaLat,
        AppConstants.tirumalaLng,
        AppConstants.tirupatiStationLat,
        AppConstants.tirupatiStationLng,
        isTirumalaDestination: false,
      );

      // Down-Ghat road (19.5 km) + Alipiri to Station should be approx 22 - 27 km
      expect(dist, greaterThan(21.0));
      expect(dist, lessThan(30.0));
    });
  });
}
