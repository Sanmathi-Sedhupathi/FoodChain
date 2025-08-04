import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<Position?> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      if (_currentPosition != null) {
        await _getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    _currentAddress = await getAddressFromCoordinates(latitude, longitude);
  }

  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return [];
    }
  }

  GeoPoint? get currentGeoPoint {
    if (_currentPosition == null) return null;
    return GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
  }

  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convert to kilometers
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}