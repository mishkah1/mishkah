import 'package:flutter/material.dart';
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
  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);

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
            title: const Text('الفرص',
                style: TextStyle(color: _cream, fontSize: 16, fontWeight: FontWeight.w600)),
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
          child: Center(child: CircularProgressIndicator(color: _darkGreen)),
        ),
      );
    }

    if (opportunities.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(
            child: Text('ما فيه فرص متاحة حاليا',
                style: TextStyle(fontSize: 13, color: _muted)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            right: BorderSide(
              color: opp.role == OpportunityRole.teacher ? _gold : _darkGreen,
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
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
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
                  color: _muted,
                ),
                const SizedBox(width: 4),
                Text(
                  opp.isInPerson ? opp.district : 'أونلاين',
                  style: const TextStyle(fontSize: 11.5, color: _muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(opp.salary,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E1B12))),
                Text(opp.ageRangeLabel,
                    style: const TextStyle(fontSize: 11, color: _muted)),
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
        color: opp.isInPerson ? const Color(0xFFEAF3DE) : const Color(0xFFEAF1F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        opp.isInPerson ? 'حضوري' : 'أونلاين',
        style: TextStyle(
          fontSize: 10,
          color: opp.isInPerson ? const Color(0xFF2D4A16) : const Color(0xFF1E4A6B),
        ),
      ),
    );
  }
}