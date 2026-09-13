/// طريقة الحضور: حضوري أو أونلاين.
enum AttendanceType { inPerson, online }

/// الفئة المستهدفة من الحلقة.
enum HalaqaCategory { female, male, kids }

/// نوع الحلقة: حفظ، مراجعة، تجويد، أو ترتيل.
enum HalaqaFocus { memorization, review, tajweed, recitation }

/// وقت انعقاد الحلقة (محدد بالصلاة اللي بعدها).
enum HalaqaTime { fajr, asr, maghrib, isha }

/// حالة التسجيل بالحلقة.
enum RegistrationStatus { open, comingSoon, closed }

/// يمثل بيانات حلقة تحفيظ واحدة، سواء تابعة لدار حضوري أو حلقة أونلاين.
class HalaqaModel {
  final String id;
  final String name;

  /// null لو الحلقة أونلاين بالكامل وما تتبع دار معين.
  final String? darId;

  final AttendanceType attendanceType;
  final HalaqaCategory category;
  final HalaqaFocus focus;
  final HalaqaTime time;
  final bool hasDaycare;

  /// رقم الطابق، يظهر فقط لو الحلقة حضورية.
  final String? floor;

  final RegistrationStatus registrationStatus;

  /// رابط التسجيل الخاص بالحلقة (موقع الدار أو نموذج مستقل).
  final String? registrationUrl;

  /// رقم تواصل بديل يظهر لو ما فيه رابط تسجيل.
  final String? contactPhone;

  /// رابط الاجتماع (زوم مثلا) لو الحلقة أونلاين.
  final String? onlineMeetingUrl;

  HalaqaModel({
    required this.id,
    required this.name,
    this.darId,
    required this.attendanceType,
    required this.category,
    required this.focus,
    required this.time,
    this.hasDaycare = false,
    this.floor,
    required this.registrationStatus,
    this.registrationUrl,
    this.contactPhone,
    this.onlineMeetingUrl,
  });

  /// true لو الحلقة تابعة لدار (حضورية ومرتبطة بمكان فعلي).
  bool get belongsToDar => darId != null && darId!.isNotEmpty;

  /// true لو فيه رابط تسجيل فعلي، وإلا نعرض رقم التواصل.
  bool get hasRegistrationLink =>
      registrationUrl != null && registrationUrl!.trim().isNotEmpty;

  factory HalaqaModel.fromJson(Map<String, dynamic> json) {
    return HalaqaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      darId: json['dar_id'] as String?,
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
      hasDaycare: json['has_daycare'] as bool? ?? false,
      floor: json['floor'] as String?,
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
      'has_daycare': hasDaycare,
      'floor': floor,
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
      case HalaqaFocus.recitation:
        return 'ترتيل';
    }
  }
}


extension HalaqaTimeLabel on HalaqaTime {
  String get label {
    switch (this) {
      case HalaqaTime.fajr:
        return 'فجر';
      case HalaqaTime.asr:
        return 'عصر';
      case HalaqaTime.maghrib:
        return 'مغرب';
      case HalaqaTime.isha:
        return 'عشاء';
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