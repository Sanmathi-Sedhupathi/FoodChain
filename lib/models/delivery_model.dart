import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus { assigned, pickedUp, delivered, cancelled }

class DeliveryModel {
  final String id;
  final String donationId;
  final String driverId;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint dropLocation;
  final String dropAddress;
  final DeliveryStatus status;
  final DateTime assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? notes;

  DeliveryModel({
    required this.id,
    required this.donationId,
    required this.driverId,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.dropLocation,
    required this.dropAddress,
    required this.status,
    required this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
  });

  factory DeliveryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryModel(
      id: doc.id,
      donationId: data['donationId'] ?? '',
      driverId: data['driverId'] ?? '',
      pickupLocation: data['pickupLocation'] as GeoPoint,
      pickupAddress: data['pickupAddress'] ?? '',
      dropLocation: data['dropLocation'] as GeoPoint,
      dropAddress: data['dropAddress'] ?? '',
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => DeliveryStatus.assigned,
      ),
      assignedAt: (data['assignedAt'] as Timestamp).toDate(),
      pickedUpAt: data['pickedUpAt'] != null
          ? (data['pickedUpAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donationId': donationId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'pickupAddress': pickupAddress,
      'dropLocation': dropLocation,
      'dropAddress': dropAddress,
      'status': status.toString().split('.').last,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'pickedUpAt': pickedUpAt != null
          ? Timestamp.fromDate(pickedUpAt!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'notes': notes,
    };
  }

  DeliveryModel copyWith({
    DeliveryStatus? status,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
  }) {
    return DeliveryModel(
      id: id,
      donationId: donationId,
      driverId: driverId,
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      dropLocation: dropLocation,
      dropAddress: dropAddress,
      status: status ?? this.status,
      assignedAt: assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
    );
  }
}