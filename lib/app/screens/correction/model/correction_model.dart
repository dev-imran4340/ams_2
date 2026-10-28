/// Represents a punch item to add in an attendance correction request
/// Matches schema: add[].time ("HH:MM"), add[].kind ("in"|"out"|"break_start"|"break_end"), add[].next_day
class AttendanceCorrectionPunchAddModel {
  final String time; // "HH:MM" (00:00 to 23:59)
  final String kind; // "in", "out", "break_start", "break_end"
  final bool nextDay;

  const AttendanceCorrectionPunchAddModel({
    required this.time,
    required this.kind,
    this.nextDay = false,
  });

  factory AttendanceCorrectionPunchAddModel.fromJson(
      Map<String, dynamic> json) {
    return AttendanceCorrectionPunchAddModel(
      time: json['time']?.toString() ?? '09:00',
      kind: json['kind']?.toString() ?? 'in',
      nextDay: json['next_day'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'kind': kind,
        'next_day': nextDay,
      };
}

/// Request model for POST /me/attendance/corrections
class AttendanceCorrectionSubmitModel {
  final String date; // "YYYY-MM-DD"
  final List<AttendanceCorrectionPunchAddModel> add;
  final List<String>? remove;
  final String reason;

  const AttendanceCorrectionSubmitModel({
    required this.date,
    required this.add,
    this.remove,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        if (add.isNotEmpty) 'add': add.map((e) => e.toJson()).toList(),
        if (remove != null && remove!.isNotEmpty) 'remove': remove!,
        'reason': reason,
      };
}
