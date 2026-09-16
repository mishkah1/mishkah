import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lecture_model.dart';
import '../../repositories/dar_repository.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);
  static const _border = Color(0xFFE7DFC9);

  final DarRepository _repository = DarRepository();

  late Future<List<LectureModel>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    _lecturesFuture = _repository.fetchLectures();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('المحاضرات',
            style: TextStyle(color: _cream, fontSize: 14)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LectureModel>>(
        future: _lecturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _darkGreen),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'حدث خطأ أثناء تحميل المحاضرات',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            );
          }

          final lectures = snapshot.data ?? [];

          if (lectures.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد محاضرات حاليًا',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            );
          }

          return RefreshIndicator(
            color: _darkGreen,
            onRefresh: () async {
              setState(() {
                _lecturesFuture = _repository.fetchLectures();
              });
              await _lecturesFuture;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lectures.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _buildLectureCard(lectures[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLectureCard(LectureModel lecture) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصف العلوي: اليوم والفترة يمين، الوقت يسار
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lecture.timeRangeLabel,
                style: const TextStyle(fontSize: 11.5, color: _muted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _darkGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lecture.scheduleLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // اسم المحاضرة
          Text(
            lecture.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B12),
            ),
          ),
          const SizedBox(height: 4),

          // اسم المحاضر
          Text(
            lecture.speakerName,
            style: const TextStyle(fontSize: 12.5, color: _muted),
          ),
          const SizedBox(height: 14),

          // الزر السفلي
          SizedBox(
            width: double.infinity,
            child: lecture.hasLink
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _openLink(lecture.link!),
                    icon: const Icon(Icons.open_in_new,
                        color: _gold, size: 16),
                    label: const Text(
                      'دخول المحاضرة',
                      style: TextStyle(color: _cream, fontSize: 13.5),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'سيتوفر قريبًا',
                      style: TextStyle(fontSize: 13.5, color: _muted),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}