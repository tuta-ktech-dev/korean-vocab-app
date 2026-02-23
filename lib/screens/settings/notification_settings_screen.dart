import 'package:flutter/cupertino.dart';
import '../../models/notification_settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettings _settings = NotificationSettings();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Thông báo'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Xong'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Master toggle
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _settings.enabled
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey3,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _settings.enabled
                          ? CupertinoIcons.bell_fill
                          : CupertinoIcons.bell_slash_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Thông báo'),
                  subtitle: Text(_settings.enabled ? 'Đang bật' : 'Đang tắt'),
                  trailing: CupertinoSwitch(
                    value: _settings.enabled,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(enabled: value);
                      });
                    },
                  ),
                ),
              ],
            ),

            if (_settings.enabled) ...[
              // SRS Reminder Section
              CupertinoListSection.insetGrouped(
                header: const Text('NHẮC ÔN TẬP'),
                children: [
                  CupertinoListTile(
                    title: const Text('Bật nhắc ôn tập'),
                    subtitle: const Text('Thông báo khi có từ đến hạn'),
                    trailing: CupertinoSwitch(
                      value: _settings.srsReminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(srsReminderEnabled: value);
                        });
                      },
                    ),
                  ),
                  if (_settings.srsReminderEnabled)
                    CupertinoListTile(
                      title: const Text('Giờ nhắc'),
                      trailing: Text(
                        '${_settings.srsReminderHour.toString().padLeft(2, '0')}:${_settings.srsReminderMinute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      onTap: () => _showTimePicker(
                        hour: _settings.srsReminderHour,
                        minute: _settings.srsReminderMinute,
                        onChanged: (h, m) {
                          setState(() {
                            _settings = _settings.copyWith(
                              srsReminderHour: h,
                              srsReminderMinute: m,
                            );
                          });
                        },
                      ),
                    ),
                ],
              ),

              // Random Word Section
              CupertinoListSection.insetGrouped(
                header: const Text('TỪ NGẪU NHIÊN'),
                children: [
                  CupertinoListTile(
                    title: const Text('Bật từ ngẫu nhiên'),
                    subtitle: const Text('Hiển thị từ vựng ngẫu nhiên'),
                    trailing: CupertinoSwitch(
                      value: _settings.randomWordEnabled,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(randomWordEnabled: value);
                        });
                      },
                    ),
                  ),
                  if (_settings.randomWordEnabled) ...[
                    CupertinoListTile(
                      title: const Text('Số từ mỗi ngày'),
                      trailing: Text(
                        '${_settings.randomWordCount}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      onTap: () => _showCountPicker(),
                    ),
                    CupertinoListTile(
                      title: const Text('Khung giờ'),
                      trailing: Text(
                        '${_settings.randomWordStartHour.toString().padLeft(2, '0')}:00 - ${_settings.randomWordEndHour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Options Section
              CupertinoListSection.insetGrouped(
                header: const Text('TÙY CHỌN'),
                children: [
                  CupertinoListTile(
                    title: const Text('Hiện phiên âm'),
                    trailing: CupertinoSwitch(
                      value: _settings.showPronunciation,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(showPronunciation: value);
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Âm thanh'),
                    trailing: CupertinoSwitch(
                      value: _settings.playSound,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(playSound: value);
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Rung'),
                    trailing: CupertinoSwitch(
                      value: _settings.vibrate,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(vibrate: value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTimePicker({
    required int hour,
    required int minute,
    required Function(int hour, int minute) onChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
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
                use24hFormat: true,
                onDateTimeChanged: (dateTime) {
                  onChanged(dateTime.hour, dateTime.minute);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountPicker() {
    final values = [1, 2, 3, 4, 5];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
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
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(
                  initialItem: _settings.randomWordCount - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _settings = _settings.copyWith(
                      randomWordCount: values[index],
                    );
                  });
                },
                children: values.map((v) => 
                  Center(child: Text('$v từ')),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
