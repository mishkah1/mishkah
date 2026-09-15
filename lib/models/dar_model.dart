import 'halaqa_model.dart';

/// حالة التسجيل بالدار (هل مفتوح للتسجيل حاليا أو قريبا).
enum DarRegistrationStatus { open, comingSoon, closed }

/// يمثل بيانات دار تحفيظ واحدة داخل تطبيق مشكاة.
class DarModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? websiteUrl;
  final String? imageUrl;
  final String? description;
  final String? donationLink;

  // ── التصنيفات: قوائم لأن الدار يقدم أكثر من نوع في نفس الوقت ──

  /// الأنواع المتوفرة بالدار (نسائي، رجالي، أطفال).
  final List<HalaqaCategory> categories;

  /// الأوقات المتوفرة بالدار (صباحي، مسائي).
  final List<HalaqaTime> times;

  /// الفئات العمرية المستهدفة بالدار.
  final List<AgeGroup> ageGroups;

  /// أنواع الرسوم المتوفرة بالدار (مجاني، رسوم رمزية).
  final List<FeeType> feeTypes;

  // ── خدمات الموقع ──

  final bool hasDaycare;
  final bool hasParking;
  final bool isAccessible;

  // ── حالة التسجيل بالدار ──

  final DarRegistrationStatus registrationStatus;

  final List<String> halaqaIds;

  DarModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.websiteUrl,
    this.imageUrl,
    this.description,
    this.donationLink,
    this.categories = const [],
    this.times = const [],
    this.ageGroups = const [],
    this.feeTypes = const [],
    this.hasDaycare = false,
    this.hasParking = false,
    this.isAccessible = false,
    required this.registrationStatus,
    this.halaqaIds = const [],
  });

  /// يرجع true إذا كان للدار موقع إلكتروني فعلي.
  bool get hasWebsite => websiteUrl != null && websiteUrl!.trim().isNotEmpty;

  /// يرجع true إذا كان للدار رابط تبرع فعلي.
  bool get hasDonationLink =>
      donationLink != null && donationLink!.trim().isNotEmpty;

  /// يرجع true إذا كان التسجيل بالدار مفتوح حاليا.
  bool get isRegistrationOpen =>
      registrationStatus == DarRegistrationStatus.open;

  /// دالة مساعدة: تحول قائمة نصوص من Supabase إلى قائمة enum.
  static List<T> _parseEnumList<T extends Enum>(
    dynamic raw,
    List<T> values,
  ) {
    if (raw == null) return const [];
    return (raw as List)
        .map((item) => values.firstWhere((e) => e.name == item))
        .toList();
  }

  /// تحويل صف قادم من Supabase (snake_case) إلى كائن DarModel.
  factory DarModel.fromJson(Map<String, dynamic> json) {
    return DarModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phone_number'] as String,
      websiteUrl: json['website_url'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      donationLink: json['donation_link'] as String?,
      categories:
          _parseEnumList(json['categories'], HalaqaCategory.values),
      times: _parseEnumList(json['times'], HalaqaTime.values),
      ageGroups: _parseEnumList(json['age_groups'], AgeGroup.values),
      feeTypes: _parseEnumList(json['fee_types'], FeeType.values),
      hasDaycare: json['has_daycare'] as bool? ?? false,
      hasParking: json['has_parking'] as bool? ?? false,
      isAccessible: json['is_accessible'] as bool? ?? false,
      registrationStatus: DarRegistrationStatus.values.firstWhere(
        (e) => e.name == json['registration_status'],
      ),
      // halaqaIds ما يجي من عمود بجدول dars مباشرة، يتم جلبه بطلب منفصل
      // من جدول halaqas عن طريق dar_id (شوفي DarRepository).
      halaqaIds: const [],
    );
  }

  /// تحويل الكائن إلى Map بصيغة snake_case (مفيد عند الإدراج بـ Supabase).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'website_url': websiteUrl,
      'image_url': imageUrl,
      'description': description,
      'donation_link': donationLink,
      'categories': categories.map((e) => e.name).toList(),
      'times': times.map((e) => e.name).toList(),
      'age_groups': ageGroups.map((e) => e.name).toList(),
      'fee_types': feeTypes.map((e) => e.name).toList(),
      'has_daycare': hasDaycare,
      'has_parking': hasParking,
      'is_accessible': isAccessible,
      'registration_status': registrationStatus.name,
    };
  }
}

/// تحويل حالة تسجيل الدار إلى نص عربي يُعرض بالواجهة.
extension DarRegistrationStatusLabel on DarRegistrationStatus {
  String get label {
    switch (this) {
      case DarRegistrationStatus.open:
        return 'التسجيل مفتوح';
      case DarRegistrationStatus.comingSoon:
        return 'قريبا';
      case DarRegistrationStatus.closed:
        return 'التسجيل مغلق';
    }
  }
}