import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationStatus { available, requested, assigned, completed, expired }

class DonationModel {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final int quantity;
  final DateTime expiryTime;
  final String? imageUrl;
  final GeoPoint location;
  final String address;
  final DonationStatus status;
  final DateTime createdAt;
  final String? assignedDriverId;
  final String? requesterId;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.expiryTime,
    this.imageUrl,
    required this.location,
    required this.address,
    required this.status,
    required this.createdAt,
    this.assignedDriverId,
    this.requesterId,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      donorId: data['donorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      expiryTime: (data['expiryTime'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      status: DonationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => DonationStatus.available,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      assignedDriverId: data['assignedDriverId'],
      requesterId: data['requesterId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donorId': donorId,
      'title': title,
      'description': description,
      'quantity': quantity,
      'expiryTime': Timestamp.fromDate(expiryTime),
      'imageUrl': imageUrl,
      'location': location,
      'address': address,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'assignedDriverId': assignedDriverId,
      'requesterId': requesterId,
    };
  }

  DonationModel copyWith({
    String? title,
    String? description,
    int? quantity,
    DateTime? expiryTime,
    String? imageUrl,
    GeoPoint? location,
    String? address,
    DonationStatus? status,
    String? assignedDriverId,
    String? requesterId,
  }) {
    return DonationModel(
      id: id,
      donorId: donorId,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      expiryTime: expiryTime ?? this.expiryTime,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      requesterId: requesterId ?? this.requesterId,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isAvailable => status == DonationStatus.available && !isExpired;
}