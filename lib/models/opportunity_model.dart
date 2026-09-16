/// الدور الوظيفي: معلمة/معلم أو إدارية/إداري.
enum OpportunityRole { teacher, admin }

/// الجنس المطلوب للفرصة.
enum OpportunityGender { female, male, both }

/// نوع موقع الفرصة: حضوري أو أونلاين.
enum OpportunityLocationType { inPerson, online }

/// وقت العمل: صباحي أو مسائي.
enum OpportunityWorkingTime { morning, evening }

/// يمثل فرصة عمل أو تطوع واحدة (تدريس أو عمل إداري) مرتبطة بدار أو حلقة.
class OpportunityModel {
  final String id;
  final OpportunityRole role;
  final String organizationName;
  final String description;
  final OpportunityLocationType locationType;
  final String district;
  final String city;
  final OpportunityGender gender;
  final int ageMin;
  final int ageMax;
  final String salary;
  final String requirements;
  final String workingDays;
  final OpportunityWorkingTime workingTime;
  final String contactMethod;
  final DateTime? createdAt;

  OpportunityModel({
    required this.id,
    required this.role,
    required this.organizationName,
    required this.description,
    required this.locationType,
    required this.district,
    required this.city,
    required this.gender,
    required this.ageMin,
    required this.ageMax,
    required this.salary,
    required this.requirements,
    required this.workingDays,
    required this.workingTime,
    required this.contactMethod,
    this.createdAt,
  });

  bool get isInPerson => locationType == OpportunityLocationType.inPerson;

  /// نطاق العمر جاهز للعرض، مثلا "من 22 إلى 40 سنة".
  String get ageRangeLabel => 'من $ageMin إلى $ageMax سنة';

  /// المسمى الوظيفي بالصيغة الصحيحة نحويًا حسب الدور والجنس المطلوب
  /// (معلمة/معلم/إدارية/إداري)، يُحسب مباشرة بدل ما يعتمد على النص
  /// المخزّن بقاعدة البيانات حرفيًا.
  String get roleLabel {
    switch (role) {
      case OpportunityRole.teacher:
        switch (gender) {
          case OpportunityGender.female:
            return 'معلمة';
          case OpportunityGender.male:
            return 'معلم';
          case OpportunityGender.both:
            return 'معلم / معلمة';
        }
      case OpportunityRole.admin:
        switch (gender) {
          case OpportunityGender.female:
            return 'إدارية';
          case OpportunityGender.male:
            return 'إداري';
          case OpportunityGender.both:
            return 'إداري / إدارية';
        }
    }
  }

  /// يحول أي صيغة من job_title (معلم/معلمة/إداري/إدارية) إلى OpportunityRole
  /// بغض النظر عن صيغة الجنس المخزنة بالنص.
  static OpportunityRole _parseRole(String raw) {
    return raw.startsWith('معلم') ? OpportunityRole.teacher : OpportunityRole.admin;
  }

  static OpportunityGender _parseGender(String raw) {
    switch (raw) {
      case 'أنثى':
        return OpportunityGender.female;
      case 'ذكر':
        return OpportunityGender.male;
      case 'كلاهما':
        return OpportunityGender.both;
      default:
        throw ArgumentError('قيمة جنس غير معروفة: $raw');
    }
  }

  static OpportunityLocationType _parseLocationType(String raw) {
    return raw == 'حضوري'
        ? OpportunityLocationType.inPerson
        : OpportunityLocationType.online;
  }

  static OpportunityWorkingTime _parseWorkingTime(String raw) {
    return raw == 'صباحي'
        ? OpportunityWorkingTime.morning
        : OpportunityWorkingTime.evening;
  }

  /// تحويل صف قادم من Supabase (snake_case) إلى كائن OpportunityModel.
  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] as String,
      role: _parseRole(json['job_title'] as String),
      organizationName: json['organization_name'] as String,
      description: json['description'] as String,
      locationType: _parseLocationType(json['location_type'] as String),
      district: json['district'] as String,
      city: json['city'] as String,
      gender: _parseGender(json['gender'] as String),
      ageMin: json['age_min'] as int,
      ageMax: json['age_max'] as int,
      salary: json['salary'] as String,
      requirements: json['requirements'] as String,
      workingDays: json['working_days'] as String,
      workingTime: _parseWorkingTime(json['working_time'] as String),
      contactMethod: json['contact_method'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// تحويل الكائن إلى Map بصيغة snake_case (مفيد عند الإدراج بـ Supabase).
  /// لاحظي إن job_title يُكتب هنا بالصيغة الصحيحة (roleLabel) تلقائيًا
  /// حسب الدور والجنس، بدل ما تكتبينها يدويًا وتخطئين بالتطابق.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_title': roleLabel,
      'organization_name': organizationName,
      'description': description,
      'location_type': isInPerson ? 'حضوري' : 'أونلاين',
      'district': district,
      'city': city,
      'gender': switch (gender) {
        OpportunityGender.female => 'أنثى',
        OpportunityGender.male => 'ذكر',
        OpportunityGender.both => 'كلاهما',
      },
      'age_min': ageMin,
      'age_max': ageMax,
      'salary': salary,
      'requirements': requirements,
      'working_days': workingDays,
      'working_time': workingTime == OpportunityWorkingTime.morning ? 'صباحي' : 'مسائي',
      'contact_method': contactMethod,
    };
  }
}