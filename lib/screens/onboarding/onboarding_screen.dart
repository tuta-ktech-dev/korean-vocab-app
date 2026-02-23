import 'dart:math' show pi, cos, sin;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OnboardingScreen - Giới thiệu app với animated gradients và icons
/// Không cần ảnh, dùng UI động đẹp mắt
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  late final List<OnboardingPageData> _pages;
  late final List<AnimationController> _animControllers;

  @override
  void initState() {
    super.initState();
    _pages = [
      OnboardingPageData(
        icon: CupertinoIcons.book_fill,
        iconColor: CupertinoColors.white,
        title: 'Học từ vựng tiếng Hàn',
        description:
            'Phương pháp học thông minh với SRS giúp bạn nhớ lâu hơn, quên ít hơn.',
        gradientColors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
        ],
        particleColor: const Color(0xFFa78bfa),
      ),
      OnboardingPageData(
        icon: CupertinoIcons.square_grid_2x2_fill,
        iconColor: CupertinoColors.white,
        title: '4 Chế độ học tập',
        description:
            'Flashcard, Trắc nghiệm, Tự luận, và Đảo ngược - phù hợp mọi trình độ.',
        gradientColors: const [
          Color(0xFFf093fb),
          Color(0xFFf5576c),
        ],
        particleColor: const Color(0xFFfda4af),
      ),
      OnboardingPageData(
        icon: CupertinoIcons.clock_fill,
        iconColor: CupertinoColors.white,
        title: 'Ôn tập thông minh',
        description:
            'Hệ thống tự động nhắc nhở ôn tập đúng thở điểm tối ưu.',
        gradientColors: const [
          Color(0xFF4facfe),
          Color(0xFF00f2fe),
        ],
        particleColor: const Color(0xFF7dd3fc),
      ),
      OnboardingPageData(
        icon: CupertinoIcons.rocket_fill,
        iconColor: CupertinoColors.white,
        title: 'Sẵn sàng bắt đầu?',
        description:
            'Hành trình học tiếng Hàn của bạn bắt đầu ngay bây giờ!',
        gradientColors: const [
          Color(0xFF43e97b),
          Color(0xFF38f9d7),
        ],
        particleColor: const Color(0xFF86efac),
        isLastPage: true,
      ),
    ];

    // Tạo animation controllers
    _animControllers = List.generate(
      _pages.length,
      (index) => AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _currentPage == _pages.length - 1 ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _completeOnboarding(),
                ),
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
                  return _buildPage(_pages[index], _animControllers[index]);
                },
              ),
            ),

            // Bottom section
            Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(
                children: [
                  // Page indicator
                  _buildPageIndicator(),
                  const SizedBox(height: 32),

                  // Button
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: _currentPage == index
                ? LinearGradient(
                    colors: _pages[_currentPage].gradientColors,
                  )
                : null,
            color: _currentPage == index ? null : CupertinoColors.systemGrey4,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLast = _pages[_currentPage].isLastPage;
    final gradientColors = _pages[_currentPage].gradientColors;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        onPressed: () {
          if (_currentPage < _pages.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          } else {
            _completeOnboarding();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Bắt đầu ngay' : 'Tiếp theo',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page, AnimationController animController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated illustration
          _buildAnimatedIllustration(page, animController),
          const SizedBox(height: 48),

          // Title
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              page.title,
              key: ValueKey(page.title),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              page.description,
              key: ValueKey(page.description),
              style: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.systemGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIllustration(
    OnboardingPageData page,
    AnimationController controller,
  ) {
    return SizedBox(
      width: 260,
      height: 260,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Animated background circles
              ...List.generate(3, (index) {
                final delay = index * 0.3;
                final animValue =
                    ((controller.value + delay) % 1.0);
                final scale = 0.6 + (animValue * 0.4);
                final opacity = 1.0 - animValue;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          page.gradientColors[0].withValues(
                            alpha: opacity * 0.3,
                          ),
                          page.gradientColors[1].withValues(
                            alpha: opacity * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Floating particles
              ...List.generate(6, (index) {
                final angle = (index / 6) * 2 * pi;
                final radius = 100 + (controller.value * 20);
                final x = cos(angle + controller.value * 2 * pi) * radius;
                final y = sin(angle + controller.value * 2 * pi) * radius;

                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 8 + (index % 3) * 4,
                    height: 8 + (index % 3) * 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.particleColor.withValues(
                        alpha: 0.4 + (controller.value * 0.4),
                      ),
                    ),
                  ),
                );
              }),

              // Main icon container
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: page.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.gradientColors[0].withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 70,
                  color: page.iconColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final Color particleColor;
  final bool isLastPage;

  OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.particleColor,
    this.isLastPage = false,
  });
}
