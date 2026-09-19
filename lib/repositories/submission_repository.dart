import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pending_dar_model.dart';
import '../models/pending_halaqa_model.dart';

class SubmissionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<void> submitDar(PendingDarModel dar) async {
    final uid = _uid;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولًا');
    await _client.from('pending_dars').insert({
      ...dar.toInsertJson(),
      'submitted_by': uid,
    });
  }

  Future<void> submitHalaqa(PendingHalaqaModel halaqa) async {
    final uid = _uid;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولًا');
    await _client.from('pending_halaqas').insert({
      ...halaqa.toInsertJson(),
      'submitted_by': uid,
    });
  }

  Future<List<PendingDarModel>> fetchMySubmittedDars() async {
    final uid = _uid;
    if (uid == null) return [];
    final response = await _client
        .from('pending_dars')
        .select()
        .eq('submitted_by', uid)
        .order('submitted_at', ascending: false);
    return (response as List)
        .map((row) => PendingDarModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<PendingHalaqaModel>> fetchMySubmittedHalaqas() async {
    final uid = _uid;
    if (uid == null) return [];
    final response = await _client
        .from('pending_halaqas')
        .select()
        .eq('submitted_by', uid)
        .order('submitted_at', ascending: false);
    return (response as List)
        .map(
            (row) => PendingHalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> fetchCurrentUserRole() async {
    final uid = _uid;
    if (uid == null) return 'user';
    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      return (response != null ? response['role'] as String? : null) ?? 'user';
    } catch (e) {
      return 'user';
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    return (await fetchCurrentUserRole()) == 'admin';
  }

  Future<void> becomeSubmitter() async {
    await _client.rpc('request_submitter_role');
  }

  Future<List<PendingDarModel>> fetchPendingDars() async {
    final response = await _client
        .from('pending_dars')
        .select()
        .eq('status', 'pending')
        .order('submitted_at', ascending: true);
    return (response as List)
        .map((row) => PendingDarModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<PendingHalaqaModel>> fetchPendingHalaqas() async {
    final response = await _client
        .from('pending_halaqas')
        .select()
        .eq('status', 'pending')
        .order('submitted_at', ascending: true);
    return (response as List)
        .map(
            (row) => PendingHalaqaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveDar(
    PendingDarModel request, {
    Map<String, dynamic>? edits,
  }) async {
    final darData = {...request.toDarInsertJson(), ...?edits};
    await _client.from('dars').insert(darData);
    await _client.from('pending_dars').update({
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', request.id);
  }

  Future<void> approveHalaqa(
    PendingHalaqaModel request, {
    String? darId,
    Map<String, dynamic>? edits,
  }) async {
    final halaqaData = {
      ...request.toHalaqaInsertJson(darId: darId),
      ...?edits,
    };
    await _client.from('halaqas').insert(halaqaData);
    await _client.from('pending_halaqas').update({
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', request.id);
  }

  Future<void> rejectDar(String id, {String? note}) async {
    await _client.from('pending_dars').update({
      'status': 'rejected',
      'admin_note': note,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> rejectHalaqa(String id, {String? note}) async {
    await _client.from('pending_halaqas').update({
      'status': 'rejected',
      'admin_note': note,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
