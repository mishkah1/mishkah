

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dar_model.dart';

/// صفحة التبرع: صورة موحدة + آية ثابتة + كارد ينقل لرابط التبرع
/// الخاص بجمعية مكنون.
class DonationScreen extends StatelessWidget {
  final DarModel dar;

  const DonationScreen({super.key, required this.dar});

  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);
  static const _border = Color(0xFFE7DFC9);

  static const _bannerImage = 'assets/images/donation_banner.jpg';

  static const _donationLink = 'https://store.maknon.org.sa/aedgqg?srsltid=AU7gw4Xec9KAubGrJiRHPuRY_bqGVIsytHQFqSxqxWRFc5WF9c_gS8G1';

  static const _verseSource = 'سورة البقرة - آية 245';

  Future<void> _openDonationLink(BuildContext context) async {
    final uri = Uri.parse(_donationLink);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح رابط التبرع'),
        ),
      );
    }
  }

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
              icon: const Icon(
                Icons.arrow_forward,
                color: _gold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'التبرع',
              style: TextStyle(
                color: _cream,
                fontSize: 14,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBannerImage(),
                  const SizedBox(height: 20),
                  _buildVerseCard(),
                  const SizedBox(height: 20),
                  _buildDonationCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        _bannerImage,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFEFE7D4),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.image_outlined,
            color: _muted,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
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
          const Text(
            'مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFF1E1B12),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFF1E1B12),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            _verseSource,
            style: TextStyle(
              fontSize: 11.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openDonationLink(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _darkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: _gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تبرع الآن في جمعية مكنون',
                    style: TextStyle(
                      color: _cream,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'راح ينقلك لصفحة التبرع بموقع الجمعية المحتضنة',
                    style: TextStyle(
                      color: Color(0xFFCFC9B8),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios,
              color: _gold,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}