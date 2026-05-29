import 'package:flutter/material.dart';
import 'package:inventory_apps/utils/color.dart';
import 'package:inventory_apps/views/login_page.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:lottie/lottie.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final String asset;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.asset,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Manage Your Inventory\nEasily',
      subtitle:
          'Track your items, monitor stock levels,\nand manage your warehouse efficiently!',
      asset: "assets/icons/asset1.json",
    ),
    OnboardingData(
      title: 'Stay Organized &\nIn Control',
      subtitle:
          'Get real-time updates and keep your\ninventory always up to date.',
      asset: "assets/icons/asset2.json",
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Expanded(
                          child: Center(child: Lottie.asset(data.asset)),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primaryBlue
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: CustomButton(
                label: _currentPage < _pages.length - 1
                    ? 'Next'
                    : 'Get Started',
                onTap: _onNext,
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
