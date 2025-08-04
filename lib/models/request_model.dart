import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected, completed }

class RequestModel {
  final String id;
  final String donationId;
  final String receiverId;
  final RequestStatus status;
  final DateTime requestedAt;
  final String? message;
  final DateTime? respondedAt;

  RequestModel({
    required this.id,
    required this.donationId,
    required this.receiverId,
    required this.status,
    required this.requestedAt,
    this.message,
    this.respondedAt,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      donationId: data['donationId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      message: data['message'],
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donationId': donationId,
      'receiverId': receiverId,
      'status': status.toString().split('.').last,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'message': message,
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
    };
  }

  RequestModel copyWith({
    RequestStatus? status,
    String? message,
    DateTime? respondedAt,
  }) {
    return RequestModel(
      id: id,
      donationId: donationId,
      receiverId: receiverId,
      status: status ?? this.status,
      requestedAt: requestedAt,
      message: message ?? this.message,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}