import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/models/halaqa_model.dart';

class FilterScreen extends StatefulWidget {
  final List<HalaqaModel> halaqas;
  final String category;

  const FilterScreen({
    super.key,
    required this.halaqas,
    required this.category,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _sand = Color(0xFFC0A06A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);
  static const _textMuted = Color(0xFF7E8882);
  static const _selectedBg = Color(0xFF23201A);
  static const _headerGradientStart = Color(0xFF101916);
  static const _headerGradientEnd = Color(0xFF263D32);

  static const List<String> _pagesOrder = [
    'نصف وجه',
    'وجه واحد',
    'وجهين',
    'ثلاث أوجه',
    'أربع أوجه',
  ];

  AttendanceType? selectedAttendance;
  HalaqaTime? selectedTime;
  HalaqaCategory? selectedCategory;
  AgeGroup? selectedAgeGroup;
  FeeType? selectedFee;
  RegistrationStatus? selectedRegistration;
  String? selectedNisab;
  String? selectedOnlineTime;

  bool parking = false;
  bool accessible = false;
  bool daycare = false;

  bool get isReview => widget.category == 'المراجعة';

  bool get isMemorization => widget.category == 'الحفظ';

  bool get showPagesFilter => isReview || isMemorization;

  bool get hasAnyFilter {
    return selectedAttendance != null ||
        selectedTime != null ||
        selectedCategory != null ||
        selectedAgeGroup != null ||
        selectedFee != null ||
        selectedRegistration != null ||
        selectedNisab != null ||
        selectedOnlineTime != null ||
        parking ||
        accessible ||
        daycare;
  }

  int get activeFilterCount {
    int count = 0;

    if (selectedAttendance != null) count++;
    if (selectedTime != null) count++;
    if (selectedCategory != null) count++;
    if (selectedAgeGroup != null) count++;
    if (selectedFee != null) count++;
    if (selectedRegistration != null) count++;
    if (selectedNisab != null) count++;
    if (selectedOnlineTime != null) count++;
    if (parking) count++;
    if (accessible) count++;
    if (daycare) count++;

    return count;
  }

  List<String> get onlineTimes {
    final values = <String>{};

    for (final halaqa in widget.halaqas) {
      if (halaqa.attendanceType == AttendanceType.online &&
          halaqa.time2 != null &&
          halaqa.time3 != null) {
        values.add(
          '${_formatTime(halaqa.time2!)} - ${_formatTime(halaqa.time3!)}',
        );
      }
    }

    final result = values.toList();
    result.sort();
    return result;
  }

  List<String> get nisabValues {
    final values = widget.halaqas
        .where((halaqa) => halaqa.nisab != null)
        .map((halaqa) => halaqa.nisab!.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort((a, b) {
      final indexA = _pagesOrder.indexOf(a);
      final indexB = _pagesOrder.indexOf(b);
      final rankA = indexA == -1 ? _pagesOrder.length : indexA;
      final rankB = indexB == -1 ? _pagesOrder.length : indexB;

      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }

      return a.compareTo(b);
    });

    return values;
  }

  String _formatTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);

    if (hour == null) {
      return value;
    }

    final minute =
        parts[1].length >= 2 ? parts[1].substring(0, 2) : parts[1];

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute$period';
  }

  List<HalaqaModel> get filteredResults {
    return widget.halaqas.where((halaqa) {
      if (selectedAttendance != null &&
          halaqa.attendanceType != selectedAttendance) {
        return false;
      }

      if (selectedTime != null && halaqa.time != selectedTime) {
        return false;
      }

      if (selectedCategory != null &&
          halaqa.category != selectedCategory) {
        return false;
      }

      if (selectedAgeGroup != null &&
          halaqa.ageGroup != selectedAgeGroup) {
        return false;
      }

      if (selectedFee != null && halaqa.feeType != selectedFee) {
        return false;
      }

      if (selectedRegistration != null &&
          halaqa.registrationStatus != selectedRegistration) {
        return false;
      }

      if (parking && halaqa.hasParking != true) {
        return false;
      }

      if (accessible && halaqa.isAccessible != true) {
        return false;
      }

      if (daycare && halaqa.hasDaycare != true) {
        return false;
      }

      if (selectedNisab != null && halaqa.nisab != selectedNisab) {
        return false;
      }

      if (selectedOnlineTime != null) {
        if (halaqa.time2 == null || halaqa.time3 == null) {
          return false;
        }

        final time =
            '${_formatTime(halaqa.time2!)} - ${_formatTime(halaqa.time3!)}';

        if (time != selectedOnlineTime) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void resetFilters() {
    setState(() {
      selectedAttendance = null;
      selectedTime = null;
      selectedCategory = null;
      selectedAgeGroup = null;
      selectedFee = null;
      selectedRegistration = null;
      selectedNisab = null;
      selectedOnlineTime = null;
      parking = false;
      accessible = false;
      daycare = false;
    });
  }

  void applyFilter() {
    Navigator.pop(context, filteredResults);
  }

  @override
  Widget build(BuildContext context) {
    final isInPerson = selectedAttendance == AttendanceType.inPerson;
    final isOnline = selectedAttendance == AttendanceType.online;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      24,
                    ),
                    children: [
                      _buildSection(
                        icon: Icons.location_on_outlined,
                        title: 'طريقة الحضور',
                        subtitle: 'اختاري الطريقة المناسبة لك',
                        child: Column(
                          children: [
                            _buildLargeChoice(
                              icon: Icons.apartment_rounded,
                              title: 'حضوري',
                              subtitle: 'الحلقات داخل الدار',
                              selected: isInPerson,
                              onTap: () {
                                setState(() {
                                  selectedAttendance = isInPerson
                                      ? null
                                      : AttendanceType.inPerson;
                                  selectedOnlineTime = null;
                                });
                              },
                            ),
                            const SizedBox(height: 9),
                            _buildLargeChoice(
                              icon: Icons.language_rounded,
                              title: 'أونلاين',
                              subtitle: 'الحلقات عن بُعد',
                              selected: isOnline,
                              onTap: () {
                                setState(() {
                                  selectedAttendance = isOnline
                                      ? null
                                      : AttendanceType.online;
                                  selectedTime = null;
                                  parking = false;
                                  accessible = false;
                                  daycare = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      if (isInPerson) ...[
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.schedule_rounded,
                          title: 'وقت الحلقة',
                          subtitle: 'متى تفضلين الحضور؟',
                          child: _buildChips([
                            _buildChip(
                              'صباحي',
                              selectedTime == HalaqaTime.morning,
                              Icons.wb_sunny_outlined,
                              () {
                                setState(() {
                                  selectedTime =
                                      selectedTime == HalaqaTime.morning
                                          ? null
                                          : HalaqaTime.morning;
                                });
                              },
                            ),
                            _buildChip(
                              'مسائي',
                              selectedTime == HalaqaTime.evening,
                              Icons.nightlight_outlined,
                              () {
                                setState(() {
                                  selectedTime =
                                      selectedTime == HalaqaTime.evening
                                          ? null
                                          : HalaqaTime.evening;
                                });
                              },
                            ),
                          ]),
                        ),
                      ],

                      if (isOnline) ...[
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.access_time_rounded,
                          title: 'وقت التسميع',
                          subtitle: 'اختاري الوقت المناسب لك',
                          child: onlineTimes.isEmpty
                              ? _buildEmptyOption(
                                  'لا توجد أوقات تسميع متاحة حاليًا',
                                )
                              : _buildChips(
                                  onlineTimes.map((time) {
                                    return _buildChip(
                                      time,
                                      selectedOnlineTime == time,
                                      Icons.schedule_rounded,
                                      () {
                                        setState(() {
                                          selectedOnlineTime =
                                              selectedOnlineTime == time
                                                  ? null
                                                  : time;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.groups_2_outlined,
                        title: 'الفئة',
                        subtitle: 'لمن تبحثين عن الحلقة؟',
                        child: _buildChips([
                          _buildChip(
                            'نساء',
                            selectedCategory == HalaqaCategory.female,
                            Icons.woman_2_outlined,
                            () {
                              setState(() {
                                selectedCategory =
                                    selectedCategory ==
                                            HalaqaCategory.female
                                        ? null
                                        : HalaqaCategory.female;
                              });
                            },
                          ),
                          _buildChip(
                            'رجال',
                            selectedCategory == HalaqaCategory.male,
                            Icons.man_2_outlined,
                            () {
                              setState(() {
                                selectedCategory =
                                    selectedCategory ==
                                            HalaqaCategory.male
                                        ? null
                                        : HalaqaCategory.male;
                              });
                            },
                          ),
                          _buildChip(
                            'أطفال',
                            selectedCategory == HalaqaCategory.kids,
                            Icons.child_care_outlined,
                            () {
                              setState(() {
                                selectedCategory =
                                    selectedCategory ==
                                            HalaqaCategory.kids
                                        ? null
                                        : HalaqaCategory.kids;
                              });
                            },
                          ),
                        ]),
                      ),

                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.person_outline_rounded,
                        title: 'الفئة العمرية',
                        subtitle: 'حددي العمر المناسب',
                        child: _buildChips([
                          _buildChip(
                            'أطفال',
                            selectedAgeGroup == AgeGroup.kids,
                            Icons.child_friendly_outlined,
                            () {
                              setState(() {
                                selectedAgeGroup =
                                    selectedAgeGroup == AgeGroup.kids
                                        ? null
                                        : AgeGroup.kids;
                              });
                            },
                          ),
                          _buildChip(
                            'ناشئة',
                            selectedAgeGroup == AgeGroup.youth,
                            Icons.auto_awesome_outlined,
                            () {
                              setState(() {
                                selectedAgeGroup =
                                    selectedAgeGroup == AgeGroup.youth
                                        ? null
                                        : AgeGroup.youth;
                              });
                            },
                          ),
                          _buildChip(
                            'بالغون',
                            selectedAgeGroup == AgeGroup.adults,
                            Icons.person_outline_rounded,
                            () {
                              setState(() {
                                selectedAgeGroup =
                                    selectedAgeGroup == AgeGroup.adults
                                        ? null
                                        : AgeGroup.adults;
                              });
                            },
                          ),
                          _buildChip(
                            'كبار سن',
                            selectedAgeGroup == AgeGroup.seniors,
                            Icons.elderly_outlined,
                            () {
                              setState(() {
                                selectedAgeGroup =
                                    selectedAgeGroup == AgeGroup.seniors
                                        ? null
                                        : AgeGroup.seniors;
                              });
                            },
                          ),
                        ]),
                      ),

                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.payments_outlined,
                        title: 'الرسوم',
                        subtitle: 'اختاري حسب ميزانيتك',
                        child: _buildChips([
                          _buildChip(
                            'مجاني',
                            selectedFee == FeeType.free,
                            Icons.volunteer_activism_outlined,
                            () {
                              setState(() {
                                selectedFee = selectedFee == FeeType.free
                                    ? null
                                    : FeeType.free;
                              });
                            },
                          ),
                          _buildChip(
                            'رسوم رمزية',
                            selectedFee == FeeType.symbolic,
                            Icons.payments_outlined,
                            () {
                              setState(() {
                                selectedFee =
                                    selectedFee == FeeType.symbolic
                                        ? null
                                        : FeeType.symbolic;
                              });
                            },
                          ),
                        ]),
                      ),

                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.event_available_outlined,
                        title: 'حالة التسجيل',
                        subtitle: 'هل التسجيل متاح الآن؟',
                        child: _buildChips([
                          _buildChip(
                            'مفتوح',
                            selectedRegistration ==
                                RegistrationStatus.open,
                            Icons.check_circle_outline_rounded,
                            () {
                              setState(() {
                                selectedRegistration =
                                    selectedRegistration ==
                                            RegistrationStatus.open
                                        ? null
                                        : RegistrationStatus.open;
                              });
                            },
                          ),
                          _buildChip(
                            'قريبًا',
                            selectedRegistration ==
                                RegistrationStatus.comingSoon,
                            Icons.schedule_outlined,
                            () {
                              setState(() {
                                selectedRegistration =
                                    selectedRegistration ==
                                            RegistrationStatus.comingSoon
                                        ? null
                                        : RegistrationStatus.comingSoon;
                              });
                            },
                          ),
                          _buildChip(
                            'مغلق',
                            selectedRegistration ==
                                RegistrationStatus.closed,
                            Icons.lock_outline_rounded,
                            () {
                              setState(() {
                                selectedRegistration =
                                    selectedRegistration ==
                                            RegistrationStatus.closed
                                        ? null
                                        : RegistrationStatus.closed;
                              });
                            },
                          ),
                        ]),
                      ),

                      if (isInPerson) ...[
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.workspace_premium_outlined,
                          title: 'الخدمات',
                          subtitle: 'مرافق تجعل حضورك أسهل',
                          child: Column(
                            children: [
                              _buildService(
                                icon: Icons.local_parking_outlined,
                                title: 'مواقف سيارات',
                                value: parking,
                                onChanged: (value) {
                                  setState(() => parking = value);
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildService(
                                icon: Icons.accessible_outlined,
                                title: 'تهيئة لذوي الإعاقة',
                                value: accessible,
                                onChanged: (value) {
                                  setState(() => accessible = value);
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildService(
                                icon: Icons.child_friendly_outlined,
                                title: 'حضانة',
                                value: daycare,
                                onChanged: (value) {
                                  setState(() => daycare = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (showPagesFilter) ...[
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.menu_book_rounded,
                          title: 'عدد الأوجه',
                          subtitle: isReview
                              ? 'كم وجه تودين مراجعته؟'
                              : 'كم وجه تودين حفظه؟',
                          child: nisabValues.isEmpty
                              ? _buildEmptyOption(
                                  'لا توجد خيارات متاحة حاليًا',
                                )
                              : _buildChips(
                                  nisabValues.map((nisab) {
                                    return _buildChip(
                                      nisab,
                                      selectedNisab == nisab,
                                      Icons.menu_book_outlined,
                                      () {
                                        setState(() {
                                          selectedNisab =
                                              selectedNisab == nisab
                                                  ? null
                                                  : nisab;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      _buildBottomBar(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_headerGradientStart, _headerGradientEnd],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        24,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderIcon(
                Icons.refresh_rounded,
                resetFilters,
              ),
              const Spacer(),
              Text(
                'تصفية الحلقات',
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  color: _ivory,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _buildHeaderIcon(
                Icons.arrow_forward_rounded,
                () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'اختاري ما يناسبك',
              style: GoogleFonts.amiri(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: _ivory,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'خصصي بحثك عن حلقات ${widget.category} بالطريقة التي تناسبك.',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _gold.withOpacity(.30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasAnyFilter
                        ? Icons.tune_rounded
                        : Icons.auto_awesome_outlined,
                    size: 14,
                    color: _goldLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasAnyFilter
                        ? '$activeFilterCount فلاتر محددة'
                        : 'ابدئي باختيار ما يناسبك',
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      color: _ivory,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withOpacity(.08),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: _ivory,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _gold,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        color: _ivory,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        color: _sand,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildLargeChoice({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? _selectedBg : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _gold : _border,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: selected ? _gold : _surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? _background : _textMuted,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily:
                              GoogleFonts.ibmPlexSansArabic().fontFamily,
                          color: _ivory,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily:
                              GoogleFonts.ibmPlexSansArabic().fontFamily,
                          color: _textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? _gold : _textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChips(List<Widget> chips) {
    return Wrap(
      spacing: 7,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildChip(
    String title,
    bool selected,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: selected ? _gold : _surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? _gold : _border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? _background : _sand,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  color: selected ? _background : _ivory,
                  fontSize: 10.5,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildService({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: value ? _selectedBg : _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? _gold : _border,
        ),
      ),
      child: Row(
        children: [
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _gold,
            activeThumbColor: _ivory,
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            size: 18,
            color: value ? _gold : _sand,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _ivory,
                fontSize: 11.5,
                fontWeight: value ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOption(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _surfaceRaised,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _textMuted,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _textMuted,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        0,
        2,
        0,
        4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'النتائج المتاحة',
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      color: _textMuted,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${filteredResults.length} حلقة',
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      color: _ivory,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _background,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      hasAnyFilter ? 'تطبيق الفلاتر' : 'عرض الحلقات',
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}