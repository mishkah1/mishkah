import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pending_dar_model.dart';
import '../../models/pending_halaqa_model.dart';
import '../../repositories/submission_repository.dart';

class _C {
  static const background = Color(0xFF0D1713);
  static const surface = Color(0xFF15221C);
  static const border = Color(0xFF2A3A32);
  static const gold = Color(0xFFC6A15B);
  static const ivory = Color(0xFFF4EFE3);
  static const textMuted = Color(0xFF7E8882);
}

/// يعرض للمستخدم حالة طلباته المرسلة (قيد المراجعة / مقبول / مرفوض).
class MySubmissionsScreen extends StatefulWidget {
  const MySubmissionsScreen({super.key});

  @override
  State<MySubmissionsScreen> createState() => _MySubmissionsScreenState();
}

class _MySubmissionsScreenState extends State<MySubmissionsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = SubmissionRepository();
  late TabController _tab;
  late Future<List<PendingDarModel>> _darsFuture;
  late Future<List<PendingHalaqaModel>> _halaqasFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _darsFuture = _repo.fetchMySubmittedDars();
    _halaqasFuture = _repo.fetchMySubmittedHalaqas();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Color _statusColor(SubmissionStatus s) {
    switch (s) {
      case SubmissionStatus.approved:
        return Colors.greenAccent.shade400;
      case SubmissionStatus.rejected:
        return Colors.redAccent.shade100;
      case SubmissionStatus.pending:
        return _C.gold;
    }
  }

  String _statusLabel(SubmissionStatus s) {
    switch (s) {
      case SubmissionStatus.approved:
        return 'مقبول';
      case SubmissionStatus.rejected:
        return 'مرفوض';
      case SubmissionStatus.pending:
        return 'قيد المراجعة';
    }
  }

  Widget _statusChip(SubmissionStatus s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(s).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(s).withValues(alpha: 0.4)),
      ),
      child: Text(
        _statusLabel(s),
        style: GoogleFonts.ibmPlexSansArabic(
          color: _statusColor(s),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required SubmissionStatus status,
    String? note,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: GoogleFonts.ibmPlexSansArabic(
                        color: _C.ivory, fontWeight: FontWeight.w700, fontSize: 13.5)),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 11.5)),
          if (status == SubmissionStatus.rejected && note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('سبب الرفض: $note',
                style: GoogleFonts.ibmPlexSansArabic(
                    color: Colors.redAccent.shade100, fontSize: 11)),
          ],
        ],
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
                child: Text('طلباتي',
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
                    child: Text('ما فيه طلبات دور مرسلة بعد.',
                        style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: dars
                      .map((d) => _card(
                            title: d.name,
                            subtitle: '${d.attendanceType} · ${d.registrationStatus}',
                            status: d.status,
                            note: d.adminNote,
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
                    child: Text('ما فيه طلبات حلقات مرسلة بعد.',
                        style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: halaqas
                      .map((h) => _card(
                            title: h.name,
                            subtitle: '${h.attendanceType} · ${h.focus}',
                            status: h.status,
                            note: h.adminNote,
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