import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/opportunity_model.dart';
import 'opportunity_registration_screen.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailsScreen({super.key, required this.opportunity});

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textMuted = Color(0xFF7E8882);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _surface,
            expandedHeight: 90,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward, color: _gold),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('تفاصيل الفرصة',
                style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    color: _ivory,
                    fontSize: 14)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildInfoGrid(),
                  const SizedBox(height: 16),
                  _buildSection('الوصف', opportunity.description),
                  const SizedBox(height: 12),
                  _buildSection('الشروط والمتطلبات', opportunity.requirements),
                  const SizedBox(height: 12),
                  _buildSection('التواصل / التقديم', opportunity.contactMethod),
                  const SizedBox(height: 22),
                  _buildRegisterButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _gold.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              opportunity.role == OpportunityRole.teacher
                  ? Icons.menu_book
                  : Icons.badge,
              color: _gold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            opportunity.roleLabel,
            style: GoogleFonts.amiri(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _ivory,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            opportunity.organizationName,
            style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                fontSize: 12,
                color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = <(String, String)>[
      ('الموقع', opportunity.isInPerson
          ? '${opportunity.district}، ${opportunity.city}'
          : 'أونلاين'),
      ('الجنس المطلوب', switch (opportunity.gender) {
        OpportunityGender.female => 'أنثى',
        OpportunityGender.male => 'ذكر',
        OpportunityGender.both => 'كلاهما',
      }),
      ('الفئة العمرية', opportunity.ageRangeLabel),
      ('الراتب/المكافأة', opportunity.salary),
      ('أيام العمل', opportunity.workingDays),
      ('وقت العمل', opportunity.workingTime == OpportunityWorkingTime.morning
          ? 'صباحي'
          : 'مسائي'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  right: BorderSide(color: _gold, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.$1,
                      style: TextStyle(
                          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                          fontSize: 10,
                          color: _textMuted)),
                  const SizedBox(height: 4),
                  Text(item.$2,
                      style: TextStyle(
                          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                          fontSize: 12.5,
                          color: _ivory),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _gold)),
          const SizedBox(height: 6),
          Text(content,
              style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  fontSize: 12,
                  color: _textMuted,
                  height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpportunityRegistrationScreen(opportunity: opportunity),
            ),
          );
        },
        icon: Icon(Icons.edit_note, color: _background, size: 18),
        label: Text('سجل الآن',
            style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _background,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
