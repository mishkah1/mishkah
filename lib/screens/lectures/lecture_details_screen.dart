import 'package:flutter/material.dart';
import '../../models/lecture_model.dart';
import 'lecture_registration_screen.dart';

class LectureDetailsScreen extends StatelessWidget {
  final LectureModel lecture;

  const LectureDetailsScreen({
    super.key,
    required this.lecture,
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
            title: const Text('تفاصيل المحاضرة',
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
            lecture.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lecture.speakerName,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = <(String, String)>[
      ('الوقت', lecture.timeRangeLabel),
      ('اليوم', lecture.scheduleLabel),
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
        label: const Text('سجل الآن',
            style: TextStyle(color: _cream, fontSize: 14)),
      ),
    );
  }

  void _handleRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LectureRegistrationScreen(lecture: lecture),
      ),
    );
  }
}