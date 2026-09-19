import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/opportunity_model.dart';

class OpportunityRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<OpportunityModel>> fetchAllOpportunities() async {
    final response = await _client.from('opportunities').select();
    return (response as List)
        .map((row) => OpportunityModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
