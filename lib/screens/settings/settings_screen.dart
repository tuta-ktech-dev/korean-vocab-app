import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/database/database_helper.dart';
import 'notification_settings_screen.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Cài đặt')),
      child: SafeArea(
        child: ListView(
          children: [
            // Notifications Section
            CupertinoListSection.insetGrouped(
              header: const Text('Thông báo'),
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.bell_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Thông báo học tập'),
                  subtitle: const Text('Nhắc nhở ôn tập & từ ngẫu nhiên'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Data Management Section
            CupertinoListSection.insetGrouped(
              header: const Text('Dữ liệu'),
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Xuất dữ liệu'),
                  subtitle: const Text('Lưu từ vựng ra file'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _exportData(context),
                ),
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_down_circle_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Nhập dữ liệu'),
                  subtitle: const Text('Khôi phục từ file'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _importData(context),
                ),
              ],
            ),

            // Appearance Section
            CupertinoListSection.insetGrouped(
              header: const Text('Giao diện'),
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemIndigo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.paintbrush_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Ngôn ngữ'),
                  trailing: const Text(
                    'Tiếng Việt',
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                ),
              ],
            ),

            // Support Section
            CupertinoListSection.insetGrouped(
              header: const Text('Hỗ trợ'),
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.question_circle_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Hướng dẫn sử dụng'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showHelp(context),
                ),
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.envelope_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Phản hồi'),
                  subtitle: const Text('Góp ý, báo lỗi'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showFeedback(context),
                ),
              ],
            ),

            // About Section
            CupertinoListSection.insetGrouped(
              header: const Text('Về ứng dụng'),
              children: [
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemPurple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.info_circle_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Giới thiệu'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showAbout(context),
                ),
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_text_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Điều khoản sử dụng'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showTerms(context),
                ),
                CupertinoListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.shield_fill,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Chính sách bảo mật'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showPrivacy(context),
                ),
              ],
            ),

            // App Info Footer
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.book_fill,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Từ vựng tiếng Hàn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Phiên bản 3.9.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2024',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const TutorialScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Phản hồi'),
        message: const Text('Bạn muốn góp ý hay báo lỗi?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('Góp ý tính năng');
            },
            child: const Text('Góp ý tính năng'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('Báo lỗi');
            },
            child: const Text('Báo lỗi'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail('Đánh giá ứng dụng');
            },
            child: const Text('Đánh giá ứng dụng'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  void _launchEmail(String subject) async {
    final uri = Uri.parse(
      'mailto:tutran.dev@gmail.com?subject=[$subject] Korean Vocab App',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAbout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Từ vựng tiếng Hàn'),
        content: const Column(
          children: [
            SizedBox(height: 16),
            Text(
              'Ứng dụng học từ vựng tiếng Hàn thông minh với hệ thống SRS (Spaced Repetition System).',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Tính năng chính:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '• 4 chế độ học: Flashcard, Trắc nghiệm, Tự luận\n'
              '• SRS thông minh tự động nhắc ôn tập\n'
              '• Quản lý từ vựng theo chủ đề\n'
              '• Thông báo nhắc học',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Điều khoản sử dụng'),
        content: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                '1. Chấp nhận điều khoản\n'
                'Bằng việc sử dụng ứng dụng, bạn đồng ý với các điều khoản này.\n\n'
                '2. Sử dụng hợp pháp\n'
                'Bạn cam kết sử dụng ứng dụng cho mục đích học tập hợp pháp.\n\n'
                '3. Quyền sở hữu\n'
                'Nội dung và mã nguồn ứng dụng thuộc quyền sở hữu của nhà phát triển.\n\n'
                '4. Miễn trừ trách nhiệm\n'
                'Ứng dụng được cung cấp "nguyên trạng" không có bảo đảm.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                '1. Dữ liệu cục bộ\n'
                'Tất cả dữ liệu từ vựng được lưu trữ trên thiết bị của bạn.\n\n'
                '2. Không thu thập thông tin\n'
                'Chúng tôi không thu thập bất kỳ thông tin cá nhân nào.\n\n'
                '3. Thông báo\n'
                'Thông báo được xử lý hoàn toàn trên thiết bị, không gửi lên server.\n\n'
                '4. Quyền truy cập\n'
                'Ứng dụng chỉ yêu cầu quyền thông báo để nhắc nhở học tập.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CupertinoAlertDialog(
        title: Text('Đang xuất...'),
        content: Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoActivityIndicator(),
        ),
      ),
    );

    try {
      final data = await DatabaseHelper().exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'korean_vocab_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Backup từ vựng tiếng Hàn');
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: Text('Không thể xuất dữ liệu: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return;

    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xác nhận nhập dữ liệu'),
        content: const Text(
          'Dữ liệu hiện tại sẽ bị xóa và thay thế bằng dữ liệu từ file. '
          'Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nhập'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Đang nhập...'),
          content: Padding(
            padding: EdgeInsets.all(16),
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }

    try {
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final result2 = await DatabaseHelper().importData(data);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Nhập thành công'),
            content: Text(
              'Đã nhập:\n'
              '• ${result2['imported_categories']} danh mục\n'
              '• ${result2['imported_vocabularies']} từ vựng',
            ),
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
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: Text('Không thể nhập dữ liệu: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
