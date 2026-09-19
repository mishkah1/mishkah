class LectureModel {
  final String id;
  final String title;
  final String speakerName;
  final String dayLabel;
  final String periodLabel;
  final String startTime;
  final String endTime;
  final String? link;

  LectureModel({
    required this.id,
    required this.title,
    required this.speakerName,
    required this.dayLabel,
    required this.periodLabel,
    required this.startTime,
    required this.endTime,
    this.link,
  });

  bool get hasLink => link != null && link!.trim().isNotEmpty;

  String get scheduleLabel => '$dayLabel $periodLabel';

  String get timeRangeLabel {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] as String,
      title: json['title'] as String,
      speakerName: json['speaker_name'] as String,
      dayLabel: json['day_label'] as String,
      periodLabel: json['period_label'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'speaker_name': speakerName,
      'day_label': dayLabel,
      'period_label': periodLabel,
      'start_time': startTime,
      'end_time': endTime,
      'link': link,
    };
  }
}
