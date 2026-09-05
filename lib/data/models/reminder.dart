class Reminder {
  final String id;
  final String movieId;
  final String movieTitle;
  final String cinemaName;
  final DateTime scheduledTime;
  final int leadTimeMinutes;
  final String notes;

  const Reminder({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaName,
    required this.scheduledTime,
    this.leadTimeMinutes = 30,
    this.notes = '',
  });

  DateTime get notificationTime =>
      scheduledTime.subtract(Duration(minutes: leadTimeMinutes));

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      movieId: json['movieId'] as String,
      movieTitle: json['movieTitle'] as String,
      cinemaName: json['cinemaName'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      leadTimeMinutes: (json['leadTimeMinutes'] as int?) ?? 30,
      notes: (json['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'leadTimeMinutes': leadTimeMinutes,
      'notes': notes,
    };
  }
}
