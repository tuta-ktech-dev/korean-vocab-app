import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_settings.dart';
import '../../core/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('notification_settings');

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        setState(() {
          _settings = NotificationSettings.fromMap(settingsMap);
        });
      } catch (e) {
        // Ignore parsing errors and fallback to defaults
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Thông báo học tập'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                children: [
                  // Master toggle
                  _buildMasterToggle(),

                  if (_settings.enabled) ...[
                    // SRS Reminder Section
                    _buildSectionHeaderWithIcon(
                      icon: CupertinoIcons.clock_fill,
                      title: 'Nhắc ôn tập (SRS)',
                    ),
                    _buildToggleTile(
                      title: 'Bật nhắc ôn tập',
                      subtitle: 'Thông báo khi có từ đến hạn',
                      value: _settings.srsReminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            srsReminderEnabled: value,
                          );
                        });
                      },
                    ),
                    if (_settings.srsReminderEnabled) ...[
                      _buildTimePickerTile(
                        title: 'Giờ nhắc',
                        hour: _settings.srsReminderHour,
                        minute: _settings.srsReminderMinute,
                        onChanged: (hour, minute) {
                          setState(() {
                            _settings = _settings.copyWith(
                              srsReminderHour: hour,
                              srsReminderMinute: minute,
                            );
                          });
                        },
                      ),
                    ],

                    // Random Word Section
                    _buildSectionHeaderWithIcon(
                      icon: CupertinoIcons.shuffle,
                      title: 'Từ ngẫu nhiên',
                    ),
                    _buildToggleTile(
                      title: 'Bật từ ngẫu nhiên',
                      subtitle: 'Hiển thị từ vựng ngẫu nhiên trong ngày',
                      value: _settings.randomWordEnabled,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            randomWordEnabled: value,
                          );
                        });
                      },
                    ),
                    if (_settings.randomWordEnabled) ...[
                      _buildSliderTile(
                        title: 'Số từ/ngày',
                        value: _settings.randomWordCount.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (value) {
                          setState(() {
                            _settings = _settings.copyWith(
                              randomWordCount: value.toInt(),
                            );
                          });
                        },
                      ),
                      _buildRangeTile(
                        title: 'Khung giờ',
                        startHour: _settings.randomWordStartHour,
                        endHour: _settings.randomWordEndHour,
                        onChanged: (start, end) {
                          setState(() {
                            _settings = _settings.copyWith(
                              randomWordStartHour: start,
                              randomWordEndHour: end,
                            );
                          });
                        },
                      ),
                    ],

                    // Options Section
                    _buildSectionHeaderWithIcon(
                      icon: CupertinoIcons.settings,
                      title: 'Tùy chọn',
                    ),
                    _buildToggleTile(
                      title: 'Hiện phiên âm',
                      subtitle: 'Hiển thị pronunciation trong thông báo',
                      value: _settings.showPronunciation,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            showPronunciation: value,
                          );
                        });
                      },
                    ),
                    _buildToggleTile(
                      title: 'Âm thanh',
                      subtitle: 'Phát âm thanh khi nhận thông báo',
                      value: _settings.playSound,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(playSound: value);
                        });
                      },
                    ),
                    _buildToggleTile(
                      title: 'Rung',
                      subtitle: 'Rung khi nhận thông báo',
                      value: _settings.vibrate,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(vibrate: value);
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CupertinoButton.filled(
                      onPressed: _saveSettings,
                      child: const Text('Lưu cài đặt'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _settings.enabled
            ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _settings.enabled
                ? CupertinoIcons.bell_fill
                : CupertinoIcons.bell_slash_fill,
            color: _settings.enabled
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông báo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  _settings.enabled ? 'Đang bật' : 'Đang tắt',
                  style: TextStyle(
                    color: _settings.enabled
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _settings.enabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(enabled: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderWithIcon({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: CupertinoColors.systemGrey),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required int hour,
    required int minute,
    required Function(int hour, int minute) onChanged,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text('Xong'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2024, 1, 1, hour, minute),
                    onDateTimeChanged: (dateTime) {
                      onChanged(dateTime.hour, dateTime.minute);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: CupertinoColors.systemGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                '${value.toInt()} từ',
                style: const TextStyle(color: CupertinoColors.systemGrey),
              ),
            ],
          ),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTile({
    required String title,
    required int startHour,
    required int endHour,
    required Function(int start, int end) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00',
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = _settings.toMap();
    await prefs.setString('notification_settings', json.encode(settingsMap));

    if (!_settings.enabled) {
      // Tắt hết thông báo
      final notificationService = NotificationService();
      await notificationService.cancelAll();
    } else {
      // TODO: Tích hợp logic reschedule ở App Lifecycle hoặc Vocab update,
      // vì screen này không fetch danh sách từ vựng.
    }

    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Đã lưu'),
        content: const Text('Cài đặt thông báo đã được cập nhật.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
