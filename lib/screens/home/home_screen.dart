import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';
import 'package:mishkah/repositories/dar_repository.dart';
import 'package:mishkah/services/local_saved_service.dart';
import 'package:mishkah/widgets/save_actions.dart';
import 'package:mishkah/screens/account/account_screen.dart';
import 'package:mishkah/screens/lectures/lectures_screen.dart';
import 'package:mishkah/screens/donation/donation_details_screen.dart';
import 'package:mishkah/screens/dar/dar_details_screen.dart';
import 'package:mishkah/screens/dar/dars_screen.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';
import 'package:mishkah/screens/notifications/notifications_screen.dart';
import 'package:mishkah/screens/opportunities/opportunities_screen.dart';

class _MishkahColors {
  static const background = Color(0xFF0D1713);
  static const surface = Color(0xFF15221C);
  static const surfaceRaised = Color(0xFF1B2B24);
  static const border = Color(0xFF2A3A32);
  static const green = Color(0xFF2C5142);
  static const gold = Color(0xFFC6A15B);
  static const goldLight = Color(0xFFD8BC7A);
  static const ivory = Color(0xFFF4EFE3);
  static const textSecondary = Color(0xFFA8B0AA);
  static const textMuted = Color(0xFF7E8882);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController registrationController = PageController(
    viewportFraction: 0.82,
  );

  final DarRepository repository = DarRepository();
  final LocalSavedService savedService = LocalSavedService.instance;

  List<DarModel> dars = [];
  List<HalaqaModel> openHalaqas = [];
  List<HalaqaModel> comingSoonHalaqas = [];
  bool isLoading = true;

  // كل تصنيف له لون مختلف من نفس العائلة اللونية بدل ما تكون الأربعة متطابقة.
  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'المراجعة',
      'icon': Icons.auto_stories_outlined,
      'color': Color(0xFFC6A15B),
    },
    {
      'title': 'الحفظ',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF6E907B),
    },
    {
      'title': 'التجويد',
      'icon': Icons.record_voice_over_outlined,
      'color': Color(0xFF8F7A59),
    },
    {
      'title': 'الدور',
      'icon': Icons.mosque_outlined,
      'color': Color(0xFFC0A06A),
    },
  ];

  @override
  void initState() {
    super.initState();
    savedService.addListener(onSavedItemsChanged);
    loadData();
  }

  void onSavedItemsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        repository.fetchAllDars(),
        repository.fetchOpenHalaqas(),
        repository.fetchComingSoonHalaqas(),
      ]);

      if (!mounted) return;
      setState(() {
        dars = results[0] as List<DarModel>;
        openHalaqas = results[1] as List<HalaqaModel>;
        comingSoonHalaqas = results[2] as List<HalaqaModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  List<HalaqaModel> halaqasByStatus(RegistrationStatus status) {
    if (status == RegistrationStatus.open) {
      return openHalaqas;
    }
    if (status == RegistrationStatus.comingSoon) {
      return comingSoonHalaqas;
    }
    return const [];
  }

  List<HalaqaModel> getHalaqasByFocus(
    HalaqaFocus focus,
    RegistrationStatus status,
  ) {
    return halaqasByStatus(status)
        .where((halaqa) => halaqa.focus == focus)
        .toList();
  }

  List<HalaqaModel> getDarHalaqas(RegistrationStatus status) {
    return halaqasByStatus(status)
        .where(
          (halaqa) =>
              halaqa.darId != null &&
              halaqa.darId!.isNotEmpty &&
              halaqa.attendanceType == AttendanceType.inPerson,
        )
        .toList();
  }

  DarModel? getDarById(String darId) {
    for (final dar in dars) {
      if (dar.id == darId) {
        return dar;
      }
    }
    return null;
  }

  HalaqaModel? chooseHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    Set<AttendanceType> usedAttendance,
  ) {
    final available = candidates
        .where((halaqa) => !usedIds.contains(halaqa.id))
        .toList();

    if (available.isEmpty) {
      return null;
    }

    HalaqaModel? best;
    int bestScore = -1;

    for (final halaqa in available) {
      int score = 0;
      final darId = halaqa.darId;

      if (darId != null &&
          darId.isNotEmpty &&
          !usedDarIds.contains(darId)) {
        score += 2;
      }

      if (!usedAttendance.contains(halaqa.attendanceType)) {
        score += 1;
      }

      if (best == null || score > bestScore) {
        best = halaqa;
        bestScore = score;
      }
    }

    return best;
  }

  HalaqaModel? choosePreferredHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    AttendanceType preferredAttendance,
  ) {
    final available = candidates
        .where(
          (halaqa) =>
              !usedIds.contains(halaqa.id) &&
              halaqa.attendanceType == preferredAttendance,
        )
        .toList();

    if (available.isEmpty) {
      return null;
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (darId == null ||
          darId.isEmpty ||
          !usedDarIds.contains(darId)) {
        return halaqa;
      }
    }

    return available.first;
  }

  HalaqaModel? chooseComingSoonHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    Set<AttendanceType> usedAttendance,
  ) {
    final available = candidates
        .where((halaqa) => !usedIds.contains(halaqa.id))
        .toList();

    if (available.isEmpty) {
      return null;
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (!usedAttendance.contains(halaqa.attendanceType) &&
          (darId == null ||
              darId.isEmpty ||
              !usedDarIds.contains(darId))) {
        return halaqa;
      }
    }

    for (final halaqa in available) {
      if (!usedAttendance.contains(halaqa.attendanceType)) {
        return halaqa;
      }
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (darId == null ||
          darId.isEmpty ||
          !usedDarIds.contains(darId)) {
        return halaqa;
      }
    }

    return available.first;
  }

  String getLocation(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'أونلاين';
    }

    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      final dar = getDarById(halaqa.darId!);

      if (dar != null) {
        return dar.address;
      }
    }

    return '';
  }

  String getImage(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'assets/images/online.png';
    }
    return 'assets/images/in_person.png';
  }

  String getDescription(HalaqaModel halaqa) {
    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      final dar = getDarById(halaqa.darId!);

      if (dar?.description != null &&
          dar!.description!.trim().isNotEmpty) {
        return dar.description!;
      }
    }

    return '${halaqa.time.label} - ${halaqa.category.label}';
  }

  _HomeItem? createHalaqaItem(
    HalaqaModel halaqa, {
    bool showDarName = false,
  }) {
    DarModel? dar;

    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      dar = getDarById(halaqa.darId!);
    }

    if (showDarName && dar == null) {
      return null;
    }

    return _HomeItem(
      title: showDarName ? dar!.name : halaqa.name,
      subtitle: showDarName ? halaqa.focus.label : halaqa.name,
      description: getDescription(halaqa),
      location: getLocation(halaqa),
      attendance: halaqa.attendanceType,
      image: showDarName &&
              dar!.imageUrl != null &&
              dar.imageUrl!.trim().isNotEmpty
          ? dar.imageUrl!
          : getImage(halaqa),
      imageIsNetwork: showDarName &&
          dar!.imageUrl != null &&
          dar.imageUrl!.trim().isNotEmpty,
      halaqa: halaqa,
      dar: dar,
      showDarName: showDarName,
    );
  }

  SavedItem createSavedItem(_HomeItem item) {
    return SavedItem(
      id: item.halaqa.id,
      title: item.title,
      subtitle: item.subtitle,
      description: item.description,
      location: item.location,
      attendance: item.attendance,
      image: item.image,
      imageIsNetwork: item.imageIsNetwork,
      halaqa: item.halaqa,
      dar: item.dar,
      showDarName: item.showDarName,
    );
  }

  List<_HomeItem> getOpenItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};
    final usedDarIds = <String>{};

    final darHalaqa = choosePreferredHalaqa(
      getDarHalaqas(RegistrationStatus.open),
      usedIds,
      usedDarIds,
      AttendanceType.inPerson,
    );

    if (darHalaqa != null) {
      final item = createHalaqaItem(
        darHalaqa,
        showDarName: true,
      );

      if (item != null) {
        items.add(item);
        usedIds.add(darHalaqa.id);

        if (darHalaqa.darId != null &&
            darHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(darHalaqa.darId!);
        }
      }
    }

    final reviewHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.review,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.online,
    );

    if (reviewHalaqa != null) {
      final item = createHalaqaItem(reviewHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(reviewHalaqa.id);

        if (reviewHalaqa.darId != null &&
            reviewHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(reviewHalaqa.darId!);
        }
      }
    }

    final tajweedHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.tajweed,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.inPerson,
    );

    if (tajweedHalaqa != null) {
      final item = createHalaqaItem(tajweedHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(tajweedHalaqa.id);

        if (tajweedHalaqa.darId != null &&
            tajweedHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(tajweedHalaqa.darId!);
        }
      }
    }

    final memorizationHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.memorization,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.online,
    );

    if (memorizationHalaqa != null) {
      final item = createHalaqaItem(memorizationHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(memorizationHalaqa.id);

        if (memorizationHalaqa.darId != null &&
            memorizationHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(memorizationHalaqa.darId!);
        }
      }
    }

    if (items.length < 4) {
      final usedAttendance = <AttendanceType>{};
      for (final item in items) {
        usedAttendance.add(item.attendance);
      }

      while (items.length < 4) {
        final fallback = chooseHalaqa(
          halaqasByStatus(RegistrationStatus.open),
          usedIds,
          usedDarIds,
          usedAttendance,
        );

        if (fallback == null) {
          break;
        }

        usedIds.add(fallback.id);
        final item = createHalaqaItem(fallback);

        if (item == null) {
          continue;
        }

        items.add(item);
        usedAttendance.add(fallback.attendanceType);

        if (fallback.darId != null && fallback.darId!.isNotEmpty) {
          usedDarIds.add(fallback.darId!);
        }
      }
    }

    return items;
  }

  List<_HomeItem> getComingSoonItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};
    final usedDarIds = <String>{};
    final usedAttendance = <AttendanceType>{};

    final darCandidates = getDarHalaqas(
      RegistrationStatus.comingSoon,
    );

    final darHalaqa = chooseComingSoonHalaqa(
      darCandidates,
      usedIds,
      usedDarIds,
      usedAttendance,
    );

    if (darHalaqa != null) {
      final item = createHalaqaItem(
        darHalaqa,
        showDarName: true,
      );

      if (item != null) {
        items.add(item);
        usedIds.add(darHalaqa.id);
        usedAttendance.add(darHalaqa.attendanceType);

        if (darHalaqa.darId != null &&
            darHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(darHalaqa.darId!);
        }
      }
    }

    final focusList = [
      HalaqaFocus.tajweed,
      HalaqaFocus.memorization,
      HalaqaFocus.review,
    ];

    for (final focus in focusList) {
      final halaqa = chooseComingSoonHalaqa(
        getHalaqasByFocus(
          focus,
          RegistrationStatus.comingSoon,
        ),
        usedIds,
        usedDarIds,
        usedAttendance,
      );

      if (halaqa == null) {
        continue;
      }

      final item = createHalaqaItem(halaqa);

      if (item == null) {
        continue;
      }

      items.add(item);
      usedIds.add(halaqa.id);
      usedAttendance.add(halaqa.attendanceType);

      if (halaqa.darId != null &&
          halaqa.darId!.isNotEmpty) {
        usedDarIds.add(halaqa.darId!);
      }

      if (items.length == 4) {
        break;
      }
    }

    while (items.length < 4) {
      final fallback = chooseComingSoonHalaqa(
        halaqasByStatus(RegistrationStatus.comingSoon),
        usedIds,
        usedDarIds,
        usedAttendance,
      );

      if (fallback == null) {
        break;
      }

      usedIds.add(fallback.id);
      final item = createHalaqaItem(fallback);

      if (item == null) {
        continue;
      }

      items.add(item);
      usedAttendance.add(fallback.attendanceType);

      if (fallback.darId != null && fallback.darId!.isNotEmpty) {
        usedDarIds.add(fallback.darId!);
      }
    }

    return items;
  }

  Future<void> openHomeItem(
    BuildContext context,
    _HomeItem item,
  ) async {
    if (item.showDarName && item.dar != null) {
      List<HalaqaModel> darHalaqas;

      try {
        darHalaqas = await repository.fetchHalaqasForDar(item.dar!.id);
      } catch (e) {
        darHalaqas = [
          ...openHalaqas,
          ...comingSoonHalaqas,
        ]
            .where(
              (halaqa) =>
                  halaqa.darId != null &&
                  halaqa.darId == item.dar!.id,
            )
            .toList();
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DarDetailsScreen(
            dar: item.dar!,
            halaqas: darHalaqas,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalaqaDetailsScreen(
          halaqa: item.halaqa,
          dar: item.dar,
        ),
      ),
    );
  }

  @override
  void dispose() {
    savedService.removeListener(onSavedItemsChanged);
    registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationOpen = getOpenItems();
    final comingSoon = getComingSoonItems();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: _MishkahColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MishkahBackgroundPainter(),
              ),
            ),
          ),
          Column(
            children: [
              // ── هيدر داكن راقٍ بدون بحث ──
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 950),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final translateY = 18.0 * (1.0 - value);
                  final scale = 0.985 + (0.015 * value);
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, translateY),
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF101916),
                        Color(0xFF263D32),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: _MishkahAmbientGlow(),
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.045,
                            child: CustomPaint(
                              painter: _GeometricPatternPainter(),
                            ),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _GlassIconButton(
                                  icon: Icons.notifications_none_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'مِشكاة',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiri(
                                        fontSize: 31,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                        color: const Color(0xFFF4EFE5),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'رفيقك نحو الخير والعلم',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFB8C6BE),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // خانة الحساب انتقلت من البوتوم بار إلى هنا،
                                // بنفس ارتفاع أيقونة الجرس.
                                _GlassIconButton(
                                  icon: Icons.person_outline_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AccountScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 22,
                          bottom: 17,
                          child: Container(
                            width: 42,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6A15B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 22,
                          bottom: 17,
                          child: Container(
                            width: 42,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6A15B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ── باقي المحتوى القابل للتمرير ──
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ScrollConfiguration(
                    behavior: const _NoStretchBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: categories.map((category) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DarsScreen(
                                            category: category['title'] as String,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(22),
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: _MishkahColors.surface,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: (category['color'] as Color).withOpacity(0.55),
                                          width: 1,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x22000000),
                                            blurRadius: 18,
                                            offset: Offset(0, 7),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            category['icon'] as IconData,
                                            color: _MishkahColors.ivory,
                                            size: 25,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            category['title'] as String,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                              color: const Color(0xFFE9E3D8),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                          _SectionHeader(
                            title: 'مفتوح التسجيل',
                            subtitle: registrationOpen.isEmpty
                                ? null
                                : '${registrationOpen.length} حلقات تنتظرك',
                          ),
                          const SizedBox(height: 13),
                          if (isLoading)
                            const SizedBox(
                              height: 185,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFC6A15B),
                                ),
                              ),
                            )
                          else if (registrationOpen.isEmpty)
                            const _EmptyState(
                              icon: Icons.event_busy_rounded,
                              message: 'لا توجد بيانات كافية لعرض البرامج',
                              height: 185,
                            )
                          else
                            SizedBox(
                              height: 185,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: PageView.builder(
                                  controller: registrationController,
                                  physics: const PageScrollPhysics(),
                                  itemCount: registrationOpen.length,
                                  itemBuilder: (context, index) {
                                    final item = registrationOpen[index];
                                    final savedItem = createSavedItem(item);
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: _RegistrationCard(
                                        title: item.title,
                                        subtitle: item.subtitle,
                                        description: item.description,
                                        location: item.location,
                                        attendance: item.attendance,
                                        image: item.image,
                                        imageIsNetwork: item.imageIsNetwork,
                                        savedItem: savedItem,
                                        isFavorite:
                                            savedService.isFavorite(savedItem.id),
                                        isNotificationEnabled: savedService
                                            .isNotificationEnabled(savedItem.id),
                                        onFavorite: () {
                                          savedService.toggleFavorite(savedItem);
                                        },
                                        onNotification: () {
                                          savedService
                                              .toggleNotification(savedItem);
                                        },
                                        onTap: () => openHomeItem(context, item),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 30),
                          _SectionHeader(
                            title: 'قريبًا',
                            subtitle: comingSoon.isEmpty
                                ? null
                                : 'ترقبوا فتح التسجيل قريبًا',
                          ),
                          const SizedBox(height: 13),
                          if (isLoading)
                            const SizedBox(
                              height: 130,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFC6A15B),
                                ),
                              ),
                            )
                          else if (comingSoon.isEmpty)
                            const _EmptyState(
                              icon: Icons.hourglass_empty_rounded,
                              message: 'لا توجد برامج قادمة حاليًا',
                              height: 130,
                            )
                          else
                            ...comingSoon.map(
                              (item) {
                                final savedItem = createSavedItem(item);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 13),
                                  child: _ComingSoonCard(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    description: item.description,
                                    location: item.location,
                                    attendance: item.attendance,
                                    date: 'قريبًا',
                                    image: item.image,
                                    alignment: const Alignment(0, 0),
                                    imageIsNetwork: item.imageIsNetwork,
                                    isFavorite:
                                        savedService.isFavorite(savedItem.id),
                                    isNotificationEnabled:
                                        savedService.isNotificationEnabled(
                                      savedItem.id,
                                    ),
                                    onFavorite: () {
                                      savedService.toggleFavorite(savedItem);
                                    },
                                    onNotification: () {
                                      savedService.toggleNotification(savedItem);
                                    },
                                    onTap: () => openHomeItem(context, item),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(dars: dars),
    );
  }
}

class _HomeItem {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String image;
  final bool imageIsNetwork;
  final HalaqaModel halaqa;
  final DarModel? dar;
  final bool showDarName;

  const _HomeItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    required this.halaqa,
    required this.dar,
    required this.showDarName,
    this.imageIsNetwork = false,
  });
}

/// أيقونة دائرية بخلفية زجاجية شفافة، تستخدم بالهيدر (الجرس).
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
        child: Icon(icon, color: _MishkahColors.ivory, size: 22),
      ),
    );
  }
}

/// وهج متحرك خافت جدًا يمنح الهيدر عمقًا وحياة بدون تشتيت.
class _MishkahAmbientGlow extends StatefulWidget {
  const _MishkahAmbientGlow();

  @override
  State<_MishkahAmbientGlow> createState() => _MishkahAmbientGlowState();
}

class _MishkahAmbientGlowState extends State<_MishkahAmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutSine,
        ),
        builder: (context, child) {
          final t = _controller.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.lerp(
                  const Alignment(-0.72, -0.65),
                  const Alignment(0.72, 0.35),
                  t,
                )!,
                radius: 1.05,
                colors: [
                  _MishkahColors.gold.withOpacity(0.075 + (0.045 * t)),
                  _MishkahColors.green.withOpacity(0.025 + (0.03 * (1 - t))),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// زخرفة هندسية خفيفة جدًا بخلفية الهيدر (نفس روح النمط النجمي بالسبلاش).
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _MishkahColors.gold.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 44.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 11, paint);
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 16;
    for (int i = 0; i < points; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / points);
      final r = i.isEven ? radius : radius * 0.45;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// خلفية الصفحة: عمق لوني + نجوم ثمانية + أقواس معمارية بشفافية منخفضة.
/// صُممت لتظهر كتفاصيل فاخرة عند التأمل، لا كعنصر مشتت أثناء القراءة.
class _MishkahBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _MishkahColors.background;
    canvas.drawRect(Offset.zero & size, background);

    _drawGlow(canvas, size,
        center: Offset(size.width * 0.08, size.height * 0.16),
        radius: size.width * 0.58,
        color: _MishkahColors.green,
        opacity: 0.20);

    _drawGlow(canvas, size,
        center: Offset(size.width * 0.94, size.height * 0.58),
        radius: size.width * 0.52,
        color: _MishkahColors.gold,
        opacity: 0.040);

    final starPaint = Paint()
      ..color = const Color(0xFFD6BD87).withOpacity(0.040)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    const spacing = 88.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawEightPointStar(canvas, Offset(x, y), 25, starPaint);
      }
    }

    final diamondPaint = Paint()
      ..color = const Color(0xFFD6BD87).withOpacity(0.020)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const d = 44.0;
    for (double x = -d; x < size.width + d; x += d) {
      for (double y = -d; y < size.height + d; y += d) {
        final path = Path()
          ..moveTo(x, y - 8)
          ..lineTo(x + 8, y)
          ..lineTo(x, y + 8)
          ..lineTo(x - 8, y)
          ..close();
        canvas.drawPath(path, diamondPaint);
      }
    }

    final archPaint = Paint()
      ..color = _MishkahColors.gold.withOpacity(0.028)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final left = size.width * (0.12 + i * 0.22);
      final width = size.width * 0.26;
      final top = size.height * (0.24 + i * 0.16);
      final height = size.height * 0.30;
      final rect = Rect.fromLTWH(left, top, width, height);
      canvas.drawArc(rect, math.pi, math.pi, false, archPaint);
    }
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 16;
    for (int i = 0; i < points; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / points);
      final r = i.isEven ? radius : radius * 0.43;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// عنوان قسم مع سطر فرعي اختياري (يعطي هرمية أوضح بدل النص الجاف).
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC6A15B),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC0A06A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// حالة فراغ بأيقونة بدل نص جاف بس.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double height;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF59655F)),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: const Color(0xFF7E8882),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final List<DarModel> dars;

  const _BottomNavBar({required this.dars});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'الفرص', 'icon': Icons.auto_awesome_outlined},
      {'title': 'تبرع', 'icon': Icons.volunteer_activism_outlined},
      {'title': 'محاضرات', 'icon': Icons.mic_rounded},
      {'title': 'الرئيسية', 'icon': Icons.home_outlined},
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 88,
        decoration: const BoxDecoration(
          color: _MishkahColors.surface,
          border: Border(
            top: BorderSide(color: _MishkahColors.border, width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: items.map((item) {
              final isHome = item['title'] == 'الرئيسية';
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (item['title'] == 'الفرص') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OpportunitiesScreen()));
                    }
                    if (item['title'] == 'محاضرات') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
                    }
                    if (item['title'] == 'تبرع') {
                      if (dars.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لم يتم تحميل بيانات الدور بعد')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DonationScreen(dar: dars.first)),
                      );
                    }
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: isHome ? _MishkahColors.gold.withOpacity(0.10) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHome ? _MishkahColors.gold.withOpacity(0.16) : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 23,
                            color: isHome ? _MishkahColors.goldLight : _MishkahColors.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['title'] as String,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                              fontSize: 10.5,
                              fontWeight: isHome ? FontWeight.w700 : FontWeight.w500,
                              color: isHome ? _MishkahColors.ivory : _MishkahColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String image;
  final bool imageIsNetwork;
  final SavedItem savedItem;
  final bool isFavorite;
  final bool isNotificationEnabled;
  final VoidCallback onFavorite;
  final VoidCallback onNotification;
  final VoidCallback onTap;

  const _RegistrationCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    required this.savedItem,
    required this.isFavorite,
    required this.isNotificationEnabled,
    required this.onFavorite,
    required this.onNotification,
    required this.onTap,
    this.imageIsNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: _MishkahColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _MishkahColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageIsNetwork
                        ? Image.network(
                            image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF222D28),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFFC6A15B),
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF222D28),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFFC6A15B),
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // تدرّج شفاف من الأسفل يجعل أي عنصر فوق الصورة مقروء.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.28),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // شارة حضوري/أونلاين فوق الصورة نفسها بخلفية زجاجية.
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.32),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        attendance == AttendanceType.online
                            ? 'أونلاين'
                            : 'حضوري',
                        style: TextStyle(
                          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _MishkahColors.surface,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 8,
                    right: 8,
                    child: SaveActions(
                      isFavorite: isFavorite,
                      isRegistered: isNotificationEnabled,
                      showBell: true,
                      onFavorite: onFavorite,
                      onRegister: onNotification,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                width: double.infinity,
                color: _MishkahColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFC6A15B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 9.5,
                                color: const Color(0xFFA8B0AA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Color(0xFFC0A06A),
                            ),
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 70,
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                  fontSize: 9,
                                  color: const Color(0xFF7E8882),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String date;
  final String image;
  final Alignment alignment;
  final bool imageIsNetwork;
  final bool isFavorite;
  final bool isNotificationEnabled;
  final VoidCallback onFavorite;
  final VoidCallback onNotification;
  final VoidCallback onTap;

  const _ComingSoonCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.date,
    required this.image,
    required this.alignment,
    required this.isFavorite,
    required this.isNotificationEnabled,
    required this.onFavorite,
    required this.onNotification,
    required this.onTap,
    this.imageIsNetwork = false,
  });

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E1915).withOpacity(0.90),
            border: Border.all(
              color: _MishkahColors.gold.withOpacity(0.34),
              width: 0.8,
            ),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 138,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _MishkahColors.surfaceRaised,
                _MishkahColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _MishkahColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    SizedBox(
                      width: 108,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(38),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageIsNetwork
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    alignment: alignment,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: const Color(0xFF222D28),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: _MishkahColors.gold,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    alignment: alignment,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: const Color(0xFF222D28),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: _MishkahColors.gold,
                                      ),
                                    ),
                                  ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 50, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _MishkahColors.ivory,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 11.5,
                                height: 1.45,
                                color: _MishkahColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: const BoxDecoration(
                                    color: _MishkahColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _MishkahColors.goldLight,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  attendance == AttendanceType.online ? 'أونلاين' : 'حضوري',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                                    fontSize: 10,
                                    color: _MishkahColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // الزرّان هنا مرتبطان بالكارد كاملًا، وليس بمنطقة الصورة.
              Positioned(
                top: 7,
                left: 7,
                child: _actionButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: onFavorite,
                  iconColor: isFavorite
                      ? _MishkahColors.goldLight
                      : _MishkahColors.ivory,
                ),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: _actionButton(
                  icon: isNotificationEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  onTap: onNotification,
                  iconColor: isNotificationEnabled
                      ? _MishkahColors.goldLight
                      : _MishkahColors.ivory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoStretchBehavior extends ScrollBehavior {
  const _NoStretchBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}