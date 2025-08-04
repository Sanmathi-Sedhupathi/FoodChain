import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math' as math;

import '../models/donation_model.dart';
import '../models/request_model.dart';
import '../models/delivery_model.dart';
import '../models/user_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Donations
  Future<String> createDonation(DonationModel donation) async {
    try {
      final docRef = await _firestore.collection('donations').add(donation.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  Stream<List<DonationModel>> getDonationsStream({
    String? donorId,
    DonationStatus? status,
    GeoPoint? nearLocation,
    double? radiusKm,
  }) {
    Query query = _firestore.collection('donations');

    if (donorId != null) {
      query = query.where('donorId', isEqualTo: donorId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      List<DonationModel> donations = snapshot.docs
          .map((doc) => DonationModel.fromFirestore(doc))
          .toList();

      // Filter by location if specified
      if (nearLocation != null && radiusKm != null) {
        donations = donations.where((donation) {
          final distance = _calculateDistance(
            nearLocation.latitude,
            nearLocation.longitude,
            donation.location.latitude,
            donation.location.longitude,
          );
          return distance <= radiusKm;
        }).toList();
      }

      return donations;
    });
  }

  Future<void> updateDonation(String donationId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('donations').doc(donationId).update(updates);
    } catch (e) {
      throw Exception('Failed to update donation: $e');
    }
  }

  // Requests
  Future<String> createRequest(RequestModel request) async {
    try {
      final docRef = await _firestore.collection('requests').add(request.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  Stream<List<RequestModel>> getRequestsStream({
    String? donationId,
    String? receiverId,
    RequestStatus? status,
  }) {
    Query query = _firestore.collection('requests');

    if (donationId != null) {
      query = query.where('donationId', isEqualTo: donationId);
    }

    if (receiverId != null) {
      query = query.where('receiverId', isEqualTo: receiverId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    query = query.orderBy('requestedAt', descending: true);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RequestModel.fromFirestore(doc)).toList());
  }

  Future<void> updateRequest(String requestId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('requests').doc(requestId).update(updates);
    } catch (e) {
      throw Exception('Failed to update request: $e');
    }
  }

  // Deliveries
  Future<String> createDelivery(DeliveryModel delivery) async {
    try {
      final docRef = await _firestore.collection('deliveries').add(delivery.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create delivery: $e');
    }
  }

  Stream<List<DeliveryModel>> getDeliveriesStream({
    String? driverId,
    DeliveryStatus? status,
  }) {
    Query query = _firestore.collection('deliveries');

    if (driverId != null) {
      query = query.where('driverId', isEqualTo: driverId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    query = query.orderBy('assignedAt', descending: true);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DeliveryModel.fromFirestore(doc)).toList());
  }

  Future<void> updateDelivery(String deliveryId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('deliveries').doc(deliveryId).update(updates);
    } catch (e) {
      throw Exception('Failed to update delivery: $e');
    }
  }

  // Users
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<List<UserModel>> getDriversStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Image Upload
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}