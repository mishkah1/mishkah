/// طريقة الحضور: حضوري أو أونلاين.
enum AttendanceType { inPerson, online }

/// الفئة المستهدفة من الحلقة.
enum HalaqaCategory { female, male, kids }

/// نوع الحلقة: حفظ، مراجعة، تجويد، أو ترتيل.
enum HalaqaFocus { memorization, review, tajweed }

/// وقت انعقاد الحلقة: صباحي أو مسائي.
enum HalaqaTime { morning, evening }

/// الفئة العمرية المستهدفة.
enum AgeGroup { kids, youth, adults, seniors }

/// رسوم الحلقة: مجانية أو رسوم رمزية.
enum FeeType { free, symbolic }

/// حالة التسجيل بالحلقة.
enum RegistrationStatus { open, comingSoon, closed }

/// يمثل بيانات حلقة تحفيظ واحدة، سواء تابعة لدار حضوري أو حلقة أونلاين.
class HalaqaModel {
  final String id;
  final String name;
  final String? darId;
  final AttendanceType attendanceType;
  final HalaqaCategory category;
  final HalaqaFocus focus;
  final HalaqaTime time;
  final String? time2;
  final String? time3;
  final AgeGroup ageGroup;
  final FeeType feeType;
  final bool? hasDaycare;
  final bool? hasParking;
  final bool? isAccessible;
  final String? nisab;
  final RegistrationStatus registrationStatus;
  final String? registrationUrl;
  final String? contactPhone;
  final String? onlineMeetingUrl;

  HalaqaModel({
    required this.id,
    required this.name,
    this.darId,
    required this.attendanceType,
    required this.category,
    required this.focus,
    required this.time,
    this.time2,
    this.time3,
    required this.ageGroup,
    required this.feeType,
    this.hasDaycare,
    this.hasParking,
    this.isAccessible,
    this.nisab,
    required this.registrationStatus,
    this.registrationUrl,
    this.contactPhone,
    this.onlineMeetingUrl,
  });

  bool get belongsToDar => darId != null && darId!.trim().isNotEmpty;

  bool get isInPerson => attendanceType == AttendanceType.inPerson;

  bool get hasRegistrationLink =>
      registrationUrl != null && registrationUrl!.trim().isNotEmpty;

  factory HalaqaModel.fromJson(Map<String, dynamic> json) {
    return HalaqaModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      darId: json['dar_id']?.toString().trim(),
      attendanceType: AttendanceType.values.firstWhere(
        (e) => e.name == json['attendance_type'],
      ),
      category: HalaqaCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      focus: HalaqaFocus.values.firstWhere(
        (e) => e.name == json['focus'],
      ),
      time: HalaqaTime.values.firstWhere(
        (e) => e.name == json['time'],
      ),
      time2: json['time2']?.toString(),
      time3: json['time3']?.toString(),
      ageGroup: AgeGroup.values.firstWhere(
        (e) => e.name == json['age_group'],
      ),
      feeType: FeeType.values.firstWhere(
        (e) => e.name == json['fee_type'],
      ),
      hasDaycare: json['has_daycare'] as bool?,
      hasParking: json['has_parking'] as bool?,
      isAccessible: json['is_accessible'] as bool?,
      nisab: json['nisab']?.toString(),
      registrationStatus: RegistrationStatus.values.firstWhere(
        (e) => e.name == json['registration_status'],
      ),
      registrationUrl: json['registration_url'] as String?,
      contactPhone: json['contact_phone'] as String?,
      onlineMeetingUrl: json['online_meeting_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dar_id': darId,
      'attendance_type': attendanceType.name,
      'category': category.name,
      'focus': focus.name,
      'time': time.name,
      'time2': time2,
      'time3': time3,
      'age_group': ageGroup.name,
      'fee_type': feeType.name,
      'has_daycare': hasDaycare,
      'has_parking': hasParking,
      'is_accessible': isAccessible,
      'nisab': nisab,
      'registration_status': registrationStatus.name,
      'registration_url': registrationUrl,
      'contact_phone': contactPhone,
      'online_meeting_url': onlineMeetingUrl,
    };
  }
}

/// تحويل قيمة HalaqaFocus إلى نص عربي يُعرض بالواجهة.
extension HalaqaFocusLabel on HalaqaFocus {
  String get label {
    switch (this) {
      case HalaqaFocus.memorization:
        return 'حفظ';
      case HalaqaFocus.review:
        return 'مراجعة';
      case HalaqaFocus.tajweed:
        return 'تجويد';
    }
  }
}

extension HalaqaTimeLabel on HalaqaTime {
  String get label {
    switch (this) {
      case HalaqaTime.morning:
        return 'صباحي';
      case HalaqaTime.evening:
        return 'مسائي';
    }
  }
}

extension HalaqaCategoryLabel on HalaqaCategory {
  String get label {
    switch (this) {
      case HalaqaCategory.female:
        return 'نسائي';
      case HalaqaCategory.male:
        return 'رجالي';
      case HalaqaCategory.kids:
        return 'أطفال';
    }
  }
}

extension AgeGroupLabel on AgeGroup {
  String get label {
    switch (this) {
      case AgeGroup.kids:
        return 'أطفال';
      case AgeGroup.youth:
        return 'ناشئة';
      case AgeGroup.adults:
        return 'بالغون';
      case AgeGroup.seniors:
        return 'كبار سن';
    }
  }
}

extension FeeTypeLabel on FeeType {
  String get label {
    switch (this) {
      case FeeType.free:
        return 'مجاني';
      case FeeType.symbolic:
        return 'رسوم رمزية';
    }
  }
}