import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/opportunity_model.dart';
import '../../repositories/opportunity_repository.dart';
import 'opportunity_details_screen.dart';

/// صفحة تعرض كل فرص العمل والتطوع المتاحة، تجيب بياناتها بنفسها من Supabase.
class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  // ── هوية مِشكاة ──
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textMuted = Color(0xFF7E8882);

  final OpportunityRepository repository = OpportunityRepository();

  List<OpportunityModel> opportunities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final result = await repository.fetchAllOpportunities();
      if (!mounted) return;
      setState(() {
        opportunities = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

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
            title: Text('الفرص',
                style: GoogleFonts.amiri(
                    color: _ivory, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator(color: _gold)),
        ),
      );
    }

    if (opportunities.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Text('ما فيه فرص متاحة حاليا',
                style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    fontSize: 13,
                    color: _textMuted)),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: opportunities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildOpportunityCard(context, opportunities[index]),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, OpportunityModel opp) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailsScreen(opportunity: opp),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            right: BorderSide(
              color: opp.role == OpportunityRole.teacher ? _gold : _goldLight,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${opp.roleLabel} - ${opp.organizationName}',
                    style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: _ivory),
                  ),
                ),
                _buildLocationBadge(opp),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  opp.isInPerson ? Icons.location_on : Icons.wifi,
                  size: 13,
                  color: _textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  opp.isInPerson ? opp.district : 'أونلاين',
                  style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      fontSize: 11.5,
                      color: _textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(opp.salary,
                    style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _goldLight)),
                Text(opp.ageRangeLabel,
                    style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 11,
                        color: _textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBadge(OpportunityModel opp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: opp.isInPerson ? _gold.withOpacity(.14) : Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: opp.isInPerson ? _gold.withOpacity(.30) : Colors.white.withOpacity(.14),
        ),
      ),
      child: Text(
        opp.isInPerson ? 'حضوري' : 'أونلاين',
        style: TextStyle(
          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
          fontSize: 10,
          color: opp.isInPerson ? _goldLight : _ivory,
        ),
      ),
    );
  }
}