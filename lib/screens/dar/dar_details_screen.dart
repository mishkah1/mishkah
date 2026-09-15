import 'package:flutter/material.dart';
import '../../models/dar_model.dart';
import '../../models/halaqa_model.dart';
import '../halaqa/halaqa_details_screen.dart';

class DarDetailsScreen extends StatelessWidget {
  final DarModel dar;
  final List<HalaqaModel> halaqas;

  const DarDetailsScreen({
    super.key,
    required this.dar,
    required this.halaqas,
  });

  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);
  static const _border = Color(0xFFE7DFC9);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              title: const Text(
                'صفحة الدار',
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildDarCard(),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${halaqas.length} حلقات متوفرة في هذا الدار',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...halaqas.map(
                      (h) => _buildHalaqaTile(context, h),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE7D4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mosque,
              color: _darkGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dar.name,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1B12),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 13,
                      color: _muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dar.address,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalaqaTile(BuildContext context, HalaqaModel halaqa) {
    final isOpen =
        halaqa.registrationStatus == RegistrationStatus.open;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HalaqaDetailsScreen(
                halaqa: halaqa,
                dar: dar,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              right: BorderSide(
                color: isOpen ? _gold : _muted,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      halaqa.name,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(isOpen),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${halaqa.focus.label} - ${halaqa.time.label} - ${halaqa.category.label}',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0xFFEAF3DE)
            : const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? 'التسجيل مفتوح' : 'قريبا',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 10,
          color: isOpen
              ? const Color(0xFF2D4A16)
              : const Color(0xFF5C3D02),
        ),
      ),
    );
  }
}