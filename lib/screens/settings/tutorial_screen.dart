import 'package:flutter/cupertino.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TutorialPage> _pages = [
    TutorialPage(
      icon: CupertinoIcons.book_fill,
      iconColor: CupertinoColors.systemBlue,
      title: 'Học từ mới',
      description:
          'Bắt đầu với các từ vựng chưa từng học. App sẽ hướng dẫn bạn qua 3 chế độ: Flashcard → Trắc nghiệm → Tự luận.',
    ),
    TutorialPage(
      icon: CupertinoIcons.clock_fill,
      iconColor: CupertinoColors.systemGreen,
      title: 'Ôn tập thông minh',
      description:
          'Hệ thống SRS tự động nhắc bạn ôn tập đúng thở điểm tối ưu. Càng ôn đúng hạn, càng nhớ lâu.',
    ),
    TutorialPage(
      icon: CupertinoIcons.folder_fill,
      iconColor: CupertinoColors.systemOrange,
      title: 'Quản lý theo chủ đề',
      description:
          'Tạo Category để nhóm từ vựng theo chủ đề: Ẩm thực, Du lịch, Công sở... Thêm hình ảnh và ví dụ cho mỗi từ.',
    ),
    TutorialPage(
      icon: CupertinoIcons.bell_fill,
      iconColor: CupertinoColors.systemRed,
      title: 'Thông báo nhắc học',
      description:
          'Bật thông báo để nhận nhắc nhở ôn tập và từ vựng ngẫu nhiên mỗi ngày.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                padding: const EdgeInsets.all(16),
                child: const Text('Bỏ qua'),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(12),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Bắt đầu học'
                        : 'Tiếp theo',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.iconColor,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 17,
              color: CupertinoColors.systemGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  TutorialPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
