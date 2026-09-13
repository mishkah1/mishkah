import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dar_model.dart';
import '../../models/halaqa_model.dart';


class HalaqaDetailsScreen extends StatelessWidget {
  final HalaqaModel halaqa;


  final DarModel? dar;

  const HalaqaDetailsScreen({
    super.key,
    required this.halaqa,
    this.dar,
  });

  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);

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
            title: const Text('تفاصيل الحلقة',
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
                  _buildContactCard(),
                  const SizedBox(height: 22),
                  _buildRegisterButton(context),
                  const SizedBox(height: 10),
                  _buildDonateButton(),
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
        border: Border.all(color: const Color(0xFFE7DFC9)),
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
            child: const Icon(Icons.menu_book, color: _darkGreen),
          ),
          const SizedBox(height: 10),
          Text(
            halaqa.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dar != null ? dar!.name : 'حلقة أونلاين',
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = <(String, String)>[
      ('النوع', halaqa.focus.label),
      ('الوقت', halaqa.time.label),
      ('الفئة', halaqa.category.label),
      if (halaqa.attendanceType == AttendanceType.inPerson)
        ('الطابق', halaqa.floor ?? 'غير محدد'),
      if (halaqa.attendanceType == AttendanceType.inPerson)
        ('الحضانة', halaqa.hasDaycare ? 'متوفرة' : 'غير متوفرة'),
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
                  Text(item.$2, style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildContactCard() {
    if (halaqa.attendanceType == AttendanceType.online) {
      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.videocam, size: 16, color: _darkGreen),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'رابط الاجتماع سيتوفر بعد التسجيل',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dar != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: _darkGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(dar!.address,
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ),
              ],
            ),
          if (halaqa.contactPhone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: _darkGreen),
                const SizedBox(width: 8),
                Text(halaqa.contactPhone!,
                    style: const TextStyle(fontSize: 12, color: _muted)),
              ],
            ),
          ],
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
        onPressed: () => _handleRegister(context),
        icon: const Icon(Icons.open_in_new, color: _gold, size: 17),
        label:
            const Text('سجل الآن', style: TextStyle(color: _cream, fontSize: 14)),
      ),
    );
  }

  Widget _buildDonateButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _gold),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          // TODO: يربط لاحقا بصفحة تفاصيل التبرع
        },
        icon: const Icon(Icons.favorite_border,
            color: Color(0xFF8A5A02), size: 17),
        label: const Text(
          'تبرع لدعم هذه الحلقة',
          style: TextStyle(color: Color(0xFF8A5A02), fontSize: 14),
        ),
      ),
    );
  }


  Future<void> _handleRegister(BuildContext context) async {
    if (halaqa.hasRegistrationLink) {
      final uri = Uri.parse(halaqa.registrationUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (halaqa.contactPhone != null) {
      final uri = Uri(scheme: 'tel', path: halaqa.contactPhone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا تتوفر بيانات تسجيل لهذه الحلقة حاليا'),
        ),
      );
    }
  }
}