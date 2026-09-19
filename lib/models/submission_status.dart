enum SubmissionStatus { pending, approved, rejected }

SubmissionStatus statusFromString(String value) {
  return SubmissionStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SubmissionStatus.pending,
  );
}
