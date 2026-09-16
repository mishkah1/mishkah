import 'package:flutter/material.dart';
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
  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

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
              .where(
                (halaqa) => halaqa.focus == selectedFocus,
              )
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
      return dar.name.contains(query) ||
          dar.address.contains(query);
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
          content: Text(
            'تعذر تحميل حلقات الدار',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
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

  @override
  Widget build(BuildContext context) {
    final darResults = filteredDars;
    final halaqaResults = filteredHalaqas;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
          title: Text(
            widget.category,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _darkGreen,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  22,
                  18,
                  28,
                ),
                children: [
                  Text(
                    widget.category,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pageDescription,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: isDarCategory
                                ? 'ابحثي عن دار أو حي...'
                                : 'ابحثي عن حلقة...',
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: _muted,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE7E3D9),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE7E3D9),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: _darkGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasHalaqaFilter) ...[
                        const SizedBox(width: 9),
                        InkWell(
                          onTap: openFilter,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE7E3D9),
                              ),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: _darkGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isDarCategory
                            ? '${darResults.length} دار'
                            : '${halaqaResults.length} حلقة',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isDarCategory)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EFEA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _DarCard extends StatelessWidget {
  final DarModel dar;
  final VoidCallback onTap;

  const _DarCard({
    required this.dar,
    required this.onTap,
  });

  static const _darkGreen = Color(0xFF24483A);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE3),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: _darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  dar.name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _brown,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dar.address,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                foregroundColor: const Color(0xFFFFF8EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
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

  static const _darkGreen = Color(0xFF24483A);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);

  @override
  Widget build(BuildContext context) {
    final isOnline = halaqa.attendanceType == AttendanceType.online;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dar?.name ?? 'دار غير محددة',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              halaqa.name,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _darkGreen,
                height: 1.4,
              ),
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
              color: const Color(0xFFF8F6F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEAE4D8),
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
                    color: const Color(0xFFE1DACC),
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
                  color: const Color(0xFFE1DACC),
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
            height: 43,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                foregroundColor: const Color(0xFFFFF8EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
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

  static const _darkGreen = Color(0xFF24483A);
  static const _muted = Color(0xFF817B70);
  static const _text = Color(0xFF25231E);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: _darkGreen,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _text,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF9A7955),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF25231E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF817B70),
            ),
          ),
        ],
      ),
    );
  }
}