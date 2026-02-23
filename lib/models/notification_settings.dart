/// Settings cho Local Notifications
class NotificationSettings {
  bool enabled;
  bool srsReminderEnabled;
  bool randomWordEnabled;
  
  // SRS Reminder settings
  int srsReminderHour;      // Giờ nhắc (default: 20)
  int srsReminderMinute;    // Phút (default: 0)
  
  // Random Word settings
  int randomWordCount;      // Số từ/ngày (1-5)
  int randomWordStartHour;  // Giờ bắt đầu (default: 9)
  int randomWordEndHour;    // Giờ kết thúc (default: 21)
  
  // UI settings
  bool showPronunciation;
  bool playSound;
  bool vibrate;

  NotificationSettings({
    this.enabled = true,
    this.srsReminderEnabled = true,
    this.randomWordEnabled = true,
    this.srsReminderHour = 20,
    this.srsReminderMinute = 0,
    this.randomWordCount = 3,
    this.randomWordStartHour = 9,
    this.randomWordEndHour = 21,
    this.showPronunciation = true,
    this.playSound = true,
    this.vibrate = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'srsReminderEnabled': srsReminderEnabled,
      'randomWordEnabled': randomWordEnabled,
      'srsReminderHour': srsReminderHour,
      'srsReminderMinute': srsReminderMinute,
      'randomWordCount': randomWordCount,
      'randomWordStartHour': randomWordStartHour,
      'randomWordEndHour': randomWordEndHour,
      'showPronunciation': showPronunciation,
      'playSound': playSound,
      'vibrate': vibrate,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] ?? true,
      srsReminderEnabled: map['srsReminderEnabled'] ?? true,
      randomWordEnabled: map['randomWordEnabled'] ?? true,
      srsReminderHour: map['srsReminderHour'] ?? 20,
      srsReminderMinute: map['srsReminderMinute'] ?? 0,
      randomWordCount: map['randomWordCount'] ?? 3,
      randomWordStartHour: map['randomWordStartHour'] ?? 9,
      randomWordEndHour: map['randomWordEndHour'] ?? 21,
      showPronunciation: map['showPronunciation'] ?? true,
      playSound: map['playSound'] ?? true,
      vibrate: map['vibrate'] ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? srsReminderEnabled,
    bool? randomWordEnabled,
    int? srsReminderHour,
    int? srsReminderMinute,
    int? randomWordCount,
    int? randomWordStartHour,
    int? randomWordEndHour,
    bool? showPronunciation,
    bool? playSound,
    bool? vibrate,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      srsReminderEnabled: srsReminderEnabled ?? this.srsReminderEnabled,
      randomWordEnabled: randomWordEnabled ?? this.randomWordEnabled,
      srsReminderHour: srsReminderHour ?? this.srsReminderHour,
      srsReminderMinute: srsReminderMinute ?? this.srsReminderMinute,
      randomWordCount: randomWordCount ?? this.randomWordCount,
      randomWordStartHour: randomWordStartHour ?? this.randomWordStartHour,
      randomWordEndHour: randomWordEndHour ?? this.randomWordEndHour,
      showPronunciation: showPronunciation ?? this.showPronunciation,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
    );
  }
}
