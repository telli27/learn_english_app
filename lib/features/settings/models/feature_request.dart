import 'package:cloud_firestore/cloud_firestore.dart';

enum FeatureRequestStatus {
  inceleniyor, // Under review
  onaylandi, // Approved
  gelistiriliyor, // In development
  tamamlandi, // Completed
  reddedildi, // Rejected
}

extension FeatureRequestStatusExtension on FeatureRequestStatus {
  String get displayName {
    switch (this) {
      case FeatureRequestStatus.inceleniyor:
        return 'İnceleniyor';
      case FeatureRequestStatus.onaylandi:
        return 'Onaylandı';
      case FeatureRequestStatus.gelistiriliyor:
        return 'Geliştiriliyor';
      case FeatureRequestStatus.tamamlandi:
        return 'Tamamlandı';
      case FeatureRequestStatus.reddedildi:
        return 'Reddedildi';
    }
  }
}

class FeatureRequest {
  final String id;
  final String userId;
  final String username;
  final String requestText;
  final FeatureRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNotes;

  FeatureRequest({
    required this.id,
    required this.userId,
    required this.username,
    required this.requestText,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminNotes,
  });

  factory FeatureRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FeatureRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonim',
      requestText: data['requestText'] ?? '',
      status: _getStatusFromString(data['status'] ?? 'inceleniyor'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'requestText': requestText,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'adminNotes': adminNotes,
    };
  }

  static FeatureRequestStatus _getStatusFromString(String status) {
    switch (status) {
      case 'inceleniyor':
        return FeatureRequestStatus.inceleniyor;
      case 'onaylandi':
        return FeatureRequestStatus.onaylandi;
      case 'gelistiriliyor':
        return FeatureRequestStatus.gelistiriliyor;
      case 'tamamlandi':
        return FeatureRequestStatus.tamamlandi;
      case 'reddedildi':
        return FeatureRequestStatus.reddedildi;
      default:
        return FeatureRequestStatus.inceleniyor;
    }
  }

  FeatureRequest copyWith({
    String? id,
    String? userId,
    String? username,
    String? requestText,
    FeatureRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
  }) {
    return FeatureRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      requestText: requestText ?? this.requestText,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
