import 'package:flutter/material.dart';
import 'package:soundboard/data/const/const_values.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/library/libray.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final donateUrl = ConstValues.donateLink;
  int currentIndex = 0;

  void _openRateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void _openDonate() async {
    final uri = Uri.parse(donateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $donateUrl');
    }
  }

  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'maxammatjonov.06@gmail.com',
      queryParameters: {
        'subject': 'Feedback / Bug Report',
        'body': 'Hello,\n\nI would like to share the following feedback or report an issue:\n'
      },
    );

    await launchUrl(emailUri);
  }

  // ✅ YANGI: Tab o'zgarganda chaqiriladi
  void _onTabChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    // ✅ Agar Favorites tab ga o'tsak, qayta yuklaymiz
    if (index == 1 && mounted) {
      // Kichik delay - UI smooth bo'lishi uchun
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSegmentControl(),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: const [
                  SoundsScreen(),
                  FavoritesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.accent, AppColors.accentPink],
            ).createShader(bounds),
            child: const Text(
              'Meme Sounds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.ellipsis,
                color: AppColors.text,
                size: 20,
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      title: const Text('Options'),
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _openRateApp();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '⭐ Rate App',
                                style: TextStyle(fontSize: 16), // ✅ Kichikroq
                              ),
                            ],
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _contactUs();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '💬 Feedback / Report',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _openDonate();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '❤️ Donate / Support',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        isDefaultAction: true,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                'Sounds',
                0,
                CupertinoIcons.waveform,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildSegmentButton(
                'Favorites',
                1,
                CupertinoIcons.heart_fill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String text, int index, IconData icon) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [AppColors.accent, AppColors.accentLight],
          )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.text : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.text : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}