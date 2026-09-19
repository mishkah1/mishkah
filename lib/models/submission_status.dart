/// حالة مراجعة الطلب (دار أو حلقة) — تعريف واحد مشترك يستخدمه
/// pending_dar_model.dart و pending_halaqa_model.dart وأي شاشة تعرضهم،
/// عشان ما يصير تعارض بين نوعين بنفس الاسم (ambiguous_import).
enum SubmissionStatus { pending, approved, rejected }

SubmissionStatus statusFromString(String value) {
  return SubmissionStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SubmissionStatus.pending,
  );
}