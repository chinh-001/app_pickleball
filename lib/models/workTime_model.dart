import 'dart:convert';

/// Đại diện cho thời gian làm việc từ API
class WorkTimeModel {
  final String startTime;
  final String endTime;

  WorkTimeModel({required this.startTime, required this.endTime});

  /// Tạo từ JSON response
  factory WorkTimeModel.fromJson(Map<String, dynamic> json) {
    return WorkTimeModel(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'start_time': startTime,
    'end_time': endTime,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'WorkTimeModel(startTime: $startTime, endTime: $endTime)';
}
