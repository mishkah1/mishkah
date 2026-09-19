import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pending_dar_model.dart';
import '../../models/pending_halaqa_model.dart';
import '../../repositories/submission_repository.dart';

class _C {
  static const background = Color(0xFF0D1713);
  static const surface = Color(0xFF15221C);
  static const surfaceRaised = Color(0xFF1B2B24);
  static const border = Color(0xFF2A3A32);
  static const gold = Color(0xFFC6A15B);
  static const ivory = Color(0xFFF4EFE3);
  static const textMuted = Color(0xFF7E8882);
}

/// شاشة مراجعة طلبات الدور والحلقات المعلّقة (للإدارة فقط — RLS يمنع غيرها
/// من الوصول لهذه البيانات أصلًا حتى لو حاول فتح هذي الشاشة).
class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen>
    with SingleTickerProviderStateMixin {
  final _repo = SubmissionRepository();
  late TabController _tab;
  late Future<List<PendingDarModel>> _darsFuture;
  late Future<List<PendingHalaqaModel>> _halaqasFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    _darsFuture = _repo.fetchPendingDars();
    _halaqasFuture = _repo.fetchPendingHalaqas();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Widget _summaryCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _C.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.ibmPlexSansArabic(
                              color: _C.ivory, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: GoogleFonts.ibmPlexSansArabic(
                              color: _C.textMuted, fontSize: 11.5)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _C.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _C.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.gold),
                onPressed: () => Navigator.pop(context),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text('مراجعة الطلبات',
                    style: GoogleFonts.amiri(color: _C.ivory, fontWeight: FontWeight.w700)),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kTextTabBarHeight),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TabBar(
                    controller: _tab,
                    indicatorColor: _C.gold,
                    labelColor: _C.gold,
                    unselectedLabelColor: _C.textMuted,
                    labelStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600),
                    tabs: const [Tab(text: 'الدور'), Tab(text: 'الحلقات')],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            FutureBuilder<List<PendingDarModel>>(
              future: _darsFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _C.gold));
                }
                final dars = snap.data!;
                if (dars.isEmpty) {
                  return Center(
                    child: Text('ما فيه طلبات دور بانتظار المراجعة.',
                        style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: dars
                      .map((d) => _summaryCard(
                            title: d.name,
                            subtitle: '${d.attendanceType} · ${d.phoneNumber}',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _DarReviewDetailScreen(dar: d, repo: _repo),
                                ),
                              );
                              setState(_reload);
                            },
                          ))
                      .toList(),
                );
              },
            ),
            FutureBuilder<List<PendingHalaqaModel>>(
              future: _halaqasFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _C.gold));
                }
                final halaqas = snap.data!;
                if (halaqas.isEmpty) {
                  return Center(
                    child: Text('ما فيه طلبات حلقات بانتظار المراجعة.',
                        style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: halaqas
                      .map((h) => _summaryCard(
                            title: h.name,
                            subtitle: '${h.attendanceType} · ${h.focus}',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _HalaqaReviewDetailScreen(halaqa: h, repo: _repo),
                                ),
                              );
                              setState(_reload);
                            },
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _decoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 13),
    filled: true,
    fillColor: _C.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _C.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _C.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _C.gold),
    ),
  );
}

Widget _reviewField(TextEditingController c, String label, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory),
      decoration: _decoration(label),
    ),
  );
}

/// مراجعة/تعديل طلب دار قبل الاعتماد أو رفضه.
class _DarReviewDetailScreen extends StatefulWidget {
  final PendingDarModel dar;
  final SubmissionRepository repo;

  const _DarReviewDetailScreen({required this.dar, required this.repo});

  @override
  State<_DarReviewDetailScreen> createState() => _DarReviewDetailScreenState();
}

class _DarReviewDetailScreenState extends State<_DarReviewDetailScreen> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _mapsLink;
  late final TextEditingController _phone;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.dar.name);
    _address = TextEditingController(text: widget.dar.address ?? '');
    _mapsLink = TextEditingController(text: widget.dar.mapsLink ?? '');
    _phone = TextEditingController(text: widget.dar.phoneNumber);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _mapsLink.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    try {
      await widget.repo.approveDar(widget.dar, edits: {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'maps_link': _mapsLink.text.trim().isEmpty ? null : _mapsLink.text.trim(),
        'phone_number': _phone.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الاعتماد: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    try {
      await widget.repo.rejectDar(widget.dar.id,
          note: _note.text.trim().isEmpty ? null : _note.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الرفض: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _C.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.gold),
                onPressed: () => Navigator.pop(context),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text('مراجعة طلب دار',
                    style: GoogleFonts.amiri(color: _C.ivory, fontWeight: FontWeight.w700)),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              _reviewField(_name, 'اسم الدار'),
              _reviewField(_address, 'العنوان'),
              _reviewField(_mapsLink, 'رابط خرائط قوقل'),
              _reviewField(_phone, 'رقم التواصل'),
              const SizedBox(height: 8),
              Text('باقي البيانات (التصنيفات، الأوقات، الفئات...) كما أرسلها صاحب الدار:',
                  style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 11.5)),
              const SizedBox(height: 6),
              Text(
                'التصنيفات: ${widget.dar.categories.join(", ")}\n'
                'الأوقات: ${widget.dar.times.join(", ")}\n'
                'الفئات العمرية: ${widget.dar.ageGroups.join(", ")}\n'
                'الرسوم: ${widget.dar.feeTypes.join(", ")}\n'
                'حضانة: ${widget.dar.hasDaycare ? "نعم" : "لا"} · '
                'مواقف: ${widget.dar.hasParking ? "نعم" : "لا"} · '
                'ذوي إعاقة: ${widget.dar.isAccessible ? "نعم" : "لا"}',
                style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory, fontSize: 12.5, height: 1.6),
              ),
              const SizedBox(height: 24),
              _reviewField(_note, 'سبب الرفض (إذا رح ترفضين الطلب)', maxLines: 2),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _busy ? null : _reject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('رفض',
                            style: GoogleFonts.ibmPlexSansArabic(
                                color: Colors.redAccent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _approve,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.gold,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _busy
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text('اعتماد',
                                style: GoogleFonts.ibmPlexSansArabic(
                                    color: _C.background, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مراجعة/تعديل طلب حلقة قبل الاعتماد أو رفضه.
class _HalaqaReviewDetailScreen extends StatefulWidget {
  final PendingHalaqaModel halaqa;
  final SubmissionRepository repo;

  const _HalaqaReviewDetailScreen({required this.halaqa, required this.repo});

  @override
  State<_HalaqaReviewDetailScreen> createState() =>
      _HalaqaReviewDetailScreenState();
}

class _HalaqaReviewDetailScreenState extends State<_HalaqaReviewDetailScreen> {
  late final TextEditingController _name;
  late final TextEditingController _darId;
  late final TextEditingController _contactPhone;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.halaqa.name);
    _darId = TextEditingController();
    _contactPhone = TextEditingController(text: widget.halaqa.contactPhone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _darId.dispose();
    _contactPhone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    try {
      await widget.repo.approveHalaqa(
        widget.halaqa,
        darId: _darId.text.trim().isEmpty ? null : _darId.text.trim(),
        edits: {
          'name': _name.text.trim(),
          'contact_phone': _contactPhone.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الاعتماد: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    try {
      await widget.repo.rejectHalaqa(widget.halaqa.id,
          note: _note.text.trim().isEmpty ? null : _note.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الرفض: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _C.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.gold),
                onPressed: () => Navigator.pop(context),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text('مراجعة طلب حلقة',
                    style: GoogleFonts.amiri(color: _C.ivory, fontWeight: FontWeight.w700)),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              _reviewField(_name, 'اسم الحلقة'),
              if (widget.halaqa.darNameRef != null &&
                  widget.halaqa.darNameRef!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'اسم الدار كما كتبه المرسل: ${widget.halaqa.darNameRef}',
                    style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 12),
                  ),
                ),
              _reviewField(_darId,
                  'معرّف الدار (dar_id) — عبّيه لو الحلقة تابعة لدار موجود مسبقًا'),
              _reviewField(_contactPhone, 'رقم التواصل'),
              const SizedBox(height: 8),
              Text(
                'طريقة الحضور: ${widget.halaqa.attendanceType}\n'
                'الفئة: ${widget.halaqa.category} · النوع: ${widget.halaqa.focus}\n'
                'الوقت: ${widget.halaqa.time}'
                '${widget.halaqa.time2 != null ? " / ${widget.halaqa.time2}" : ""}'
                '${widget.halaqa.time3 != null ? " / ${widget.halaqa.time3}" : ""}\n'
                'مقدار الحفظ / النصاب: ${widget.halaqa.memorizationAmount ?? widget.halaqa.nisab ?? "-"}\n'
                'الفئة العمرية: ${widget.halaqa.ageGroup} · الرسوم: ${widget.halaqa.feeType}\n'
                'رابط التسجيل: ${widget.halaqa.registrationUrl ?? "-"}\n'
                'رابط الاجتماع الأونلاين: ${widget.halaqa.onlineMeetingUrl ?? "-"}',
                style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory, fontSize: 12.5, height: 1.6),
              ),
              const SizedBox(height: 24),
              _reviewField(_note, 'سبب الرفض (إذا رح ترفضين الطلب)', maxLines: 2),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _busy ? null : _reject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('رفض',
                            style: GoogleFonts.ibmPlexSansArabic(
                                color: Colors.redAccent, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _approve,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.gold,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _busy
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text('اعتماد',
                                style: GoogleFonts.ibmPlexSansArabic(
                                    color: _C.background, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}