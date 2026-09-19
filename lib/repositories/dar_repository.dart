import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dar_model.dart';
import '../models/halaqa_model.dart';
import '../models/lecture_model.dart';

class DarRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<DarModel>> fetchAllDars() async {
    final response = await _client.from('dars').select();
    return (response as List)
        .map((row) => DarModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<DarModel> fetchDarById(String darId) async {
    final response =
        await _client.from('dars').select().eq('id', darId).single();
    return DarModel.fromJson(response);
  }

  Future<List<HalaqaModel>> fetchHalaqasForDar(String darId) async {
    final response =
        await _client.from('halaqas').select().eq('dar_id', darId);
    return (response as List)
        .map((row) => HalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<HalaqaModel>> fetchAllHalaqas() async {
    final response = await _client.from('halaqas').select();
    return (response as List)
        .map((row) => HalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<HalaqaModel>> fetchHalaqasByStatus(
    RegistrationStatus status,
  ) async {
    final response = await _client
        .from('halaqas')
        .select()
        .eq('registration_status', status.name);

    return (response as List)
        .map((row) => HalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<HalaqaModel>> fetchOpenHalaqas() {
    return fetchHalaqasByStatus(RegistrationStatus.open);
  }

  Future<List<HalaqaModel>> fetchComingSoonHalaqas() {
    return fetchHalaqasByStatus(RegistrationStatus.comingSoon);
  }

  Future<List<DarModel>> fetchDarsByIds(List<String> darIds) async {
    if (darIds.isEmpty) return [];

    final response =
        await _client.from('dars').select().inFilter('id', darIds);

    return (response as List)
        .map((row) => DarModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<LectureModel>> fetchLectures() async {
    final response = await _client
        .from('lectures')
        .select()
        .order('start_time', ascending: true);

    return (response as List)
        .map((row) => LectureModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
