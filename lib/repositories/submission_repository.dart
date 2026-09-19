import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pending_dar_model.dart';
import '../models/pending_halaqa_model.dart';

/// مسؤول عن كل عمليات "تسجيل بيانات دار/حلقة من المستخدمين"
/// ومراجعتها واعتمادها من قبل الإدارة.
///
/// ملاحظة مهمة: هذا الملف لا يلمس جدولي dars/halaqas إلا في دالتي
/// approveDar و approveHalaqa، وفقط بعد ما تعتمدين الطلب يدويًا.
class SubmissionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  // ---------------- إرسال طلبات (submitter/admin فقط، تفرضه RLS) ----------------

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

  // ---------------- طلباتي (للمستخدم نفسه) ----------------

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

  // ---------------- دور الحساب الحالي ----------------

  /// يرجع 'user' أو 'submitter' أو 'admin'. الافتراضي 'user' لو ما فيه صف
  /// أو لو صار أي خطأ (مثلاً جدول profiles لسا ما انعمل) — عشان القسم
  /// الخاص بتسجيل البيانات ما يختفي بصمت أبدًا.
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

  /// يرقّي الحساب الحالي من 'user' إلى 'submitter' (صاحب دار/حلقة).
  /// لا يقدر يوصل لـ 'admin' عن طريق هذي الدالة إطلاقًا (محمي بقاعدة البيانات).
  Future<void> becomeSubmitter() async {
    await _client.rpc('request_submitter_role');
  }

  // ---------------- المراجعة (للإدارة فقط — RLS يمنع غيرها) ----------------

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

  /// تعتمد طلب دار: تدخل صف بجدول dars الحقيقي وتحدّث حالة الطلب.
  /// [edits] قيم معدَّلة اختيارية (لو راجعتِ الطلب وغيّرتِ شي قبل الاعتماد).
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

  /// تعتمد طلب حلقة. مرري [darId] لو الحلقة تابعة لدار معتمد مسبقًا.
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