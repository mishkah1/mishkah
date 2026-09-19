import 'submission_status.dart';
export 'submission_status.dart';

class PendingHalaqaModel {
  final String id;
  final String submittedBy;
  final SubmissionStatus status;
  final String? adminNote;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  final String name;
  final String? darNameRef;
  final String attendanceType;
  final String category;
  final String focus;
  final String time;
  final String? time2;
  final String? time3;
  final String? memorizationAmount;
  final String ageGroup;
  final String feeType;
  final String? nisab;
  final String registrationStatus;
  final String? registrationUrl;
  final String? contactPhone;
  final String? onlineMeetingUrl;

  PendingHalaqaModel({
    required this.id,
    required this.submittedBy,
    required this.status,
    this.adminNote,
    required this.submittedAt,
    this.reviewedAt,
    required this.name,
    this.darNameRef,
    required this.attendanceType,
    required this.category,
    required this.focus,
    required this.time,
    this.time2,
    this.time3,
    this.memorizationAmount,
    required this.ageGroup,
    required this.feeType,
    this.nisab,
    required this.registrationStatus,
    this.registrationUrl,
    this.contactPhone,
    this.onlineMeetingUrl,
  });

  factory PendingHalaqaModel.fromJson(Map<String, dynamic> json) {
    return PendingHalaqaModel(
      id: json['id'] as String,
      submittedBy: json['submitted_by'] as String,
      status: statusFromString(json['status'] as String),
      adminNote: json['admin_note'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      name: json['name'] as String,
      darNameRef: json['dar_name_ref'] as String?,
      attendanceType: json['attendance_type'] as String,
      category: json['category'] as String,
      focus: json['focus'] as String,
      time: json['time'] as String,
      time2: json['time2'] as String?,
      time3: json['time3'] as String?,
      memorizationAmount: json['memorization_amount'] as String?,
      ageGroup: json['age_group'] as String,
      feeType: json['fee_type'] as String,
      nisab: json['nisab'] as String?,
      registrationStatus: json['registration_status'] as String,
      registrationUrl: json['registration_url'] as String?,
      contactPhone: json['contact_phone'] as String?,
      onlineMeetingUrl: json['online_meeting_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'dar_name_ref': darNameRef,
      'attendance_type': attendanceType,
      'category': category,
      'focus': focus,
      'time': time,
      'time2': time2,
      'time3': time3,
      'memorization_amount': memorizationAmount,
      'age_group': ageGroup,
      'fee_type': feeType,
      'nisab': nisab,
      'registration_status': registrationStatus,
      'registration_url': registrationUrl,
      'contact_phone': contactPhone,
      'online_meeting_url': onlineMeetingUrl,
    };
  }

  Map<String, dynamic> toHalaqaInsertJson({String? darId}) {
    return {
      'name': name,
      'dar_id': darId,
      'attendance_type': attendanceType,
      'category': category,
      'focus': focus,
      'time': time,
      'time2': time2,
      'time3': time3,
      'age_group': ageGroup,
      'fee_type': feeType,
      'nisab': memorizationAmount ?? nisab,
      'registration_status': registrationStatus,
      'registration_url': registrationUrl,
      'contact_phone': contactPhone,
      'online_meeting_url': onlineMeetingUrl,
    };
  }
}
