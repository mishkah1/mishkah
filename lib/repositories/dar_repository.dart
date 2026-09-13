import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dar_model.dart';
import '../models/halaqa_model.dart';

/// مسؤول عن كل عمليات جلب بيانات الدور والحلقات من Supabase.
class DarRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// يرجع كل الدور المسجلة بقاعدة البيانات.
  Future<List<DarModel>> fetchAllDars() async {
    final response = await _client.from('dars').select();
    return (response as List)
        .map((row) => DarModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// يرجع دار واحد حسب المعرّف.
  Future<DarModel> fetchDarById(String darId) async {
    final response =
        await _client.from('dars').select().eq('id', darId).single();
    return DarModel.fromJson(response);
  }

  /// يرجع كل الحلقات التابعة لدار معين.
  Future<List<HalaqaModel>> fetchHalaqasForDar(String darId) async {
    final response =
        await _client.from('halaqas').select().eq('dar_id', darId);
    return (response as List)
        .map((row) => HalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// يرجع كل الحلقات بالتطبيق (تستخدم بالصفحة الرئيسية قبل التصفية).
  Future<List<HalaqaModel>> fetchAllHalaqas() async {
    final response = await _client.from('halaqas').select();
    return (response as List)
        .map((row) => HalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}