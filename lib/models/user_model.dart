import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { donor, receiver, driver }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final GeoPoint? location;
  final String? address;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.location,
    this.address,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.receiver,
      ),
      phone: data['phone'] ?? '',
      location: data['location'] as GeoPoint?,
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phone,
      'location': location,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    GeoPoint? location,
    String? address,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      address: address ?? this.address,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}