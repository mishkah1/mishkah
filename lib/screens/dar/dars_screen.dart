import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';
import 'package:mishkah/repositories/dar_repository.dart';
import 'package:mishkah/screens/dar/dar_details_screen.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';
import 'package:mishkah/screens/filter/filter_screen.dart';

class DarsScreen extends StatefulWidget {
  final String category;

  const DarsScreen({
    super.key,
    required this.category,
  });

  @override
  State<DarsScreen> createState() => _DarsScreenState();
}

class _DarsScreenState extends State<DarsScreen> {
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _darkGreen = Color(0xFF2C5142);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _cream = Color(0xFFF4EFE3);
  static const _text = Color(0xFFF4EFE3);
  static const _muted = Color(0xFFA8B0AA);
  static const _border = Color(0xFF293A32);

  final DarRepository repository = DarRepository();
  final TextEditingController searchController = TextEditingController();

  List<DarModel> dars = [];
  List<HalaqaModel> halaqas = [];
  List<HalaqaModel>? filteredHalaqasFromFilter;
  List<DarModel>? filteredDarsFromFilter;
  String? filterName;
  String? filterAddress;
  bool isLoading = true;

  bool get isDarCategory => widget.category == 'الدور';

  bool get hasHalaqaFilter =>
      widget.category == 'التجويد' ||
      widget.category == 'الحفظ' ||
      widget.category == 'المراجعة';

  HalaqaFocus? get selectedFocus {
    switch (widget.category) {
      case 'التجويد':
        return HalaqaFocus.tajweed;
      case 'الحفظ':
        return HalaqaFocus.memorization;
      case 'المراجعة':
        return HalaqaFocus.review;
      default:
        return null;
    }
  }

  String get pageDescription {
    switch (widget.category) {
      case 'الدور':
        return 'اكتشفي الدور والبرامج المتاحة لك';
      case 'التجويد':
        return 'حلقات التجويد المتاحة للتسجيل';
      case 'الحفظ':
        return 'حلقات حفظ القرآن المتاحة للتسجيل';
      case 'المراجعة':
        return 'حلقات مراجعة القرآن المتاحة للتسجيل';
      default:
        return 'اكتشفي البرامج المتاحة لك';
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(applySearch);
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      if (isDarCategory) {
        final result = await repository.fetchAllDars();
        if (!mounted) return;
        setState(() {
          dars = result;
          isLoading = false;
        });
      } else {
        final results = await Future.wait([
          repository.fetchAllHalaqas(),
          repository.fetchAllDars(),
        ]);

        final halaqaResult = results[0] as List<HalaqaModel>;
        final darResult = results[1] as List<DarModel>;

        if (!mounted) return;
        setState(() {
          dars = darResult;
          halaqas = halaqaResult
              .where((halaqa) => halaqa.focus == selectedFocus)
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void applySearch() {
    setState(() {});
  }

  List<DarModel> get filteredDars {
    final query = searchController.text.trim();
    final baseList = filteredDarsFromFilter ?? dars;

    if (query.isEmpty) {
      return baseList;
    }

    return baseList.where((dar) {
      return dar.name.contains(query) || dar.address.contains(query);
    }).toList();
  }

  List<HalaqaModel> get filteredHalaqas {
    final query = searchController.text.trim();
    final baseList = filteredHalaqasFromFilter ?? halaqas;

    if (query.isEmpty) {
      return baseList;
    }

    return baseList.where((halaqa) {
      return halaqa.name.contains(query) ||
          halaqa.focus.label.contains(query) ||
          halaqa.category.label.contains(query);
    }).toList();
  }

  Future<void> openFilter() async {
    if (!hasHalaqaFilter) {
      return;
    }

    final result = await Navigator.push<List<HalaqaModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          halaqas: halaqas,
          category: widget.category,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      filteredHalaqasFromFilter = result;
    });
  }

  Future<void> openDarDetails(DarModel dar) async {
    try {
      final darHalaqas = await repository.fetchHalaqasForDar(dar.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DarDetailsScreen(
            dar: dar,
            halaqas: darHalaqas,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _surfaceElevated,
          content: Text(
            'تعذر تحميل حلقات الدار',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(color: _cream),
          ),
        ),
      );
    }
  }

  DarModel? getDarById(String? darId) {
    if (darId == null || darId.isEmpty) {
      return null;
    }

    for (final dar in dars) {
      if (dar.id == darId) {
        return dar;
      }
    }

    return null;
  }

  void openHalaqaDetails(HalaqaModel halaqa) {
    final dar = getDarById(halaqa.darId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalaqaDetailsScreen(
          halaqa: halaqa,
          dar: dar,
        ),
      ),
    );
  }

  TextStyle _font({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = _text,
    double height = 1.35,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  TextStyle _displayFont({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color color = _cream,
  }) {
    return GoogleFonts.amiri(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final darResults = filteredDars;
    final halaqaResults = filteredHalaqas;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            widget.category,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: _displayFont(
              size: 22,
              weight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: _MishkahBackground(),
              ),
            ),
            SafeArea(
              top: false,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _gold,
                        strokeWidth: 2.2,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                      children: [
                        _PageIntro(
                          category: widget.category,
                          description: pageDescription,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Expanded(
                              child: _SearchField(
                                controller: searchController,
                                isDarCategory: isDarCategory,
                              ),
                            ),
                            if (hasHalaqaFilter) ...[
                              const SizedBox(width: 9),
                              _FilterButton(onTap: openFilter),
                            ],
                          ],
                        ),
                        const SizedBox(height: 17),
                        Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isDarCategory
                                  ? '${darResults.length} دار'
                                  : '${halaqaResults.length} حلقة',
                              textDirection: TextDirection.rtl,
                              style: _font(
                                size: 12,
                                weight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                            if (!isDarCategory)
                              _CategoryPill(
                                label: widget.category,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isDarCategory)
                          _buildDars(darResults)
                        else
                          _buildHalaqas(halaqaResults),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDars(List<DarModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.mosque_outlined,
        title: 'لا توجد دور مطابقة',
        subtitle: 'جربي البحث باسم آخر أو موقع مختلف',
      );
    }

    return Column(
      children: items.map(
        (dar) {
          return _DarCard(
            dar: dar,
            onTap: () => openDarDetails(dar),
          );
        },
      ).toList(),
    );
  }

  Widget _buildHalaqas(List<HalaqaModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'لا توجد حلقات مطابقة',
        subtitle: 'جربي تغيير خيارات التصفية أو البحث عن حلقة أخرى',
      );
    }

    return Column(
      children: items.map(
        (halaqa) {
          return _HalaqaCard(
            halaqa: halaqa,
            dar: getDarById(halaqa.darId),
            onTap: () => openHalaqaDetails(halaqa),
          );
        },
      ).toList(),
    );
  }
}

class _PageIntro extends StatelessWidget {
  final String category;
  final String description;

  const _PageIntro({
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            category,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF4EFE3),
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: [
              Flexible(
                child: Text(
                  description,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    color: const Color(0xFFA8B0AA),
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 1,
                color: const Color(0xFFC6A15B).withOpacity(0.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarCategory;

  const _SearchField({
    required this.controller,
    required this.isDarCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF15221C).withOpacity(0.96),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF293A32),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        cursorColor: const Color(0xFFC6A15B),
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 12,
          color: const Color(0xFFF4EFE3),
        ),
        decoration: InputDecoration(
          hintText: isDarCategory
              ? 'ابحثي عن دار أو حي...'
              : 'ابحثي عن حلقة...',
          hintTextDirection: TextDirection.rtl,
          hintStyle: GoogleFonts.ibmPlexSansArabic(
            color: const Color(0xFF7F8A84),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFC6A15B),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF15221C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF293A32),
          ),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: Color(0xFFC6A15B),
          size: 20,
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;

  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC6A15B).withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC6A15B).withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 10,
          color: const Color(0xFFD8BC7A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF15221C),
            border: Border.all(
              color: const Color(0xFFC6A15B).withOpacity(0.25),
              width: 0.8,
            ),
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFFF4EFE3),
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _DarCard extends StatelessWidget {
  final DarModel dar;
  final VoidCallback onTap;

  const _DarCard({
    required this.dar,
    required this.onTap,
  });

  static const _gold = Color(0xFFC6A15B);
  static const _cream = Color(0xFFF4EFE3);
  static const _muted = Color(0xFFA8B0AA);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _border = Color(0xFF293A32);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _gold.withOpacity(0.15),
                  ),
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: _gold,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  dar.name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _cream,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _gold,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dar.address,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    color: _muted,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5142),
                foregroundColor: _cream,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _gold.withOpacity(0.18),
                  ),
                ),
              ),
              child: Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HalaqaCard extends StatelessWidget {
  final HalaqaModel halaqa;
  final DarModel? dar;
  final VoidCallback onTap;

  const _HalaqaCard({
    required this.halaqa,
    required this.dar,
    required this.onTap,
  });

  static const _gold = Color(0xFFC6A15B);
  static const _cream = Color(0xFFF4EFE3);
  static const _muted = Color(0xFFA8B0AA);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _border = Color(0xFF293A32);

  @override
  Widget build(BuildContext context) {
    final isOnline = halaqa.attendanceType == AttendanceType.online;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  dar?.name ?? 'دار غير محددة',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            halaqa.name,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: _cream,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: _surfaceElevated,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _border,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                if (!isOnline) ...[
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.location_on_outlined,
                      title: 'الموقع',
                      value: dar?.address ?? 'غير محدد',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: _border,
                  ),
                ],
                Expanded(
                  child: _InfoItem(
                    icon: isOnline
                        ? Icons.videocam_outlined
                        : Icons.home_work_outlined,
                    title: 'الحضور',
                    value: isOnline ? 'أونلاين' : 'حضوري',
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: _border,
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.access_time_rounded,
                    title: 'الوقت',
                    value: halaqa.time.label,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5142),
                foregroundColor: _cream,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _gold.withOpacity(0.18),
                  ),
                ),
              ),
              child: Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const _gold = Color(0xFFC6A15B);
  static const _muted = Color(0xFFA8B0AA);
  static const _cream = Color(0xFFF4EFE3);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: _gold,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 9.5,
            color: _muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _cream,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15221C).withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF293A32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFC6A15B).withOpacity(0.09),
              border: Border.all(
                color: const Color(0xFFC6A15B).withOpacity(0.18),
              ),
            ),
            child: Icon(
              icon,
              size: 27,
              color: const Color(0xFFC6A15B),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF4EFE3),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: const Color(0xFFA8B0AA),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MishkahBackground extends StatelessWidget {
  const _MishkahBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MishkahBackgroundPainter(),
    );
  }
}

class _MishkahBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final softGold = Paint()
      ..color = const Color(0xFFC6A15B).withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final softGreen = Paint()
      ..color = const Color(0xFF2C5142).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final line = Paint()
      ..color = const Color(0xFFC6A15B).withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.08),
      size.width * 0.48,
      softGreen,
    );

    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.58),
      size.width * 0.40,
      softGold,
    );

    const spacing = 62.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);

        final path = Path()
          ..moveTo(center.dx, center.dy - 13)
          ..lineTo(center.dx + 13, center.dy)
          ..lineTo(center.dx, center.dy + 13)
          ..lineTo(center.dx - 13, center.dy)
          ..close();

        canvas.drawPath(path, line);

        final inner = Path()
          ..moveTo(center.dx, center.dy - 6)
          ..lineTo(center.dx + 6, center.dy)
          ..lineTo(center.dx, center.dy + 6)
          ..lineTo(center.dx - 6, center.dy)
          ..close();

        canvas.drawPath(inner, line);
      }
    }

    final archPaint = Paint()
      ..color = const Color(0xFFF4EFE3).withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final archWidth = size.width * 0.34;

    final arch = Path()
      ..moveTo(size.width - archWidth - 24, size.height * 0.70)
      ..lineTo(size.width - archWidth - 24, size.height * 0.84)
      ..cubicTo(
        size.width - archWidth - 24,
        size.height * 0.57,
        size.width - 24,
        size.height * 0.57,
        size.width - 24,
        size.height * 0.84,
      )
      ..lineTo(size.width - 24, size.height * 0.70);

    canvas.drawPath(arch, archPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
