import 'submission_status.dart';
export 'submission_status.dart';

class PendingDarModel {
  final String id;
  final String submittedBy;
  final SubmissionStatus status;
  final String? adminNote;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  final String name;
  final String attendanceType;
  final String? address;
  final String? mapsLink;
  final String phoneNumber;
  final String? websiteUrl;
  final String? description;
  final List<String> categories;
  final List<String> times;
  final List<String> ageGroups;
  final List<String> feeTypes;
  final bool hasDaycare;
  final bool hasParking;
  final bool isAccessible;
  final String registrationStatus;

  PendingDarModel({
    required this.id,
    required this.submittedBy,
    required this.status,
    this.adminNote,
    required this.submittedAt,
    this.reviewedAt,
    required this.name,
    required this.attendanceType,
    this.address,
    this.mapsLink,
    required this.phoneNumber,
    this.websiteUrl,
    this.description,
    this.categories = const [],
    this.times = const [],
    this.ageGroups = const [],
    this.feeTypes = const [],
    this.hasDaycare = false,
    this.hasParking = false,
    this.isAccessible = false,
    required this.registrationStatus,
  });

  bool get hasMapsLink => mapsLink != null && mapsLink!.trim().isNotEmpty;

  factory PendingDarModel.fromJson(Map<String, dynamic> json) {
    return PendingDarModel(
      id: json['id'] as String,
      submittedBy: json['submitted_by'] as String,
      status: statusFromString(json['status'] as String),
      adminNote: json['admin_note'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      name: json['name'] as String,
      attendanceType: json['attendance_type'] as String,
      address: json['address'] as String?,
      mapsLink: json['maps_link'] as String?,
      phoneNumber: json['phone_number'] as String,
      websiteUrl: json['website_url'] as String?,
      description: json['description'] as String?,
      categories: (json['categories'] as List?)?.cast<String>() ?? const [],
      times: (json['times'] as List?)?.cast<String>() ?? const [],
      ageGroups: (json['age_groups'] as List?)?.cast<String>() ?? const [],
      feeTypes: (json['fee_types'] as List?)?.cast<String>() ?? const [],
      hasDaycare: json['has_daycare'] as bool? ?? false,
      hasParking: json['has_parking'] as bool? ?? false,
      isAccessible: json['is_accessible'] as bool? ?? false,
      registrationStatus: json['registration_status'] as String,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'attendance_type': attendanceType,
      'address': address,
      'maps_link': mapsLink,
      'phone_number': phoneNumber,
      'website_url': websiteUrl,
      'description': description,
      'categories': categories,
      'times': times,
      'age_groups': ageGroups,
      'fee_types': feeTypes,
      'has_daycare': hasDaycare,
      'has_parking': hasParking,
      'is_accessible': isAccessible,
      'registration_status': registrationStatus,
    };
  }

  Map<String, dynamic> toDarInsertJson() {
    return {
      'name': name,
      'address': address ?? '',
      'maps_link': mapsLink,
      'phone_number': phoneNumber,
      'website_url': websiteUrl,
      'description': description,
      'categories': categories,
      'times': times,
      'age_groups': ageGroups,
      'fee_types': feeTypes,
      'has_daycare': hasDaycare,
      'has_parking': hasParking,
      'is_accessible': isAccessible,
      'registration_status': registrationStatus,
    };
  }
}
