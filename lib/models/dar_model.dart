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
    this.halaqaIds = const [],
  });

  /// يرجع true إذا كان للدار موقع إلكتروني فعلي.
  bool get hasWebsite => websiteUrl != null && websiteUrl!.trim().isNotEmpty;

  /// يرجع true إذا كان للدار رابط تبرع فعلي.
  bool get hasDonationLink =>
      donationLink != null && donationLink!.trim().isNotEmpty;

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
    };
  }
}