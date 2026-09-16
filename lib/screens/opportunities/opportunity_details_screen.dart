import 'package:flutter/material.dart';
import '../../models/opportunity_model.dart';
import 'opportunity_registration_screen.dart';

/// صفحة تعرض كل تفاصيل فرصة عمل أو تطوع واحدة.
class OpportunityDetailsScreen extends StatelessWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailsScreen({super.key, required this.opportunity});

  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);
  static const _border = Color(0xFFE7DFC9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _darkGreen,
            expandedHeight: 90,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward, color: _gold),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('تفاصيل الفرصة',
                style: TextStyle(color: _cream, fontSize: 14)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE7D4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              opportunity.role == OpportunityRole.teacher
                  ? Icons.menu_book
                  : Icons.badge,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            opportunity.roleLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            opportunity.organizationName,
            style: const TextStyle(fontSize: 12, color: _muted),
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
                color: Colors.white,
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
                      style: const TextStyle(fontSize: 10, color: _muted)),
                  const SizedBox(height: 4),
                  Text(item.$2,
                      style: const TextStyle(fontSize: 12.5),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1B12))),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(fontSize: 12, color: _muted, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkGreen,
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
        icon: const Icon(Icons.edit_note, color: _gold, size: 18),
        label: const Text('سجل الآن',
            style: TextStyle(color: _cream, fontSize: 14)),
      ),
    );
  }
}