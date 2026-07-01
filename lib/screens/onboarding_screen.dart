import 'package:flutter/material.dart';
import 'package:rooted/screens/home_page.dart';
import 'package:rooted/screens/auth_screen.dart';
import 'package:rooted/services/onboarding_service.dart';
import 'package:rooted/services/language_service.dart';
import 'package:rooted/l10n/app_localizations.dart';

/// Onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background soft pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/icon/app_icon.png',
                repeat: ImageRepeat.repeat,
                scale: 8,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation (Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _totalPages - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            l10n?.cancel ?? 'SKIP',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary.withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Main Content (Pages)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildModernPage(
                        image: 'assets/onboarding/welcome.webp',
                        title: 'Welcome to\nROOTED',
                        description: 'Your personal companion for spiritual growth, mindfulness, and divine connection.',
                        theme: theme,
                      ),
                      _buildModernPage(
                        image: 'assets/onboarding/growth.webp',
                        title: 'Deepen Your\nFAITH',
                        description: 'Track your Bible readings, prayers, and spiritual goals with ease and devotion.',
                        theme: theme,
                      ),
                      _buildModernPage(
                        image: 'assets/onboarding/achievement.webp',
                        title: 'Unlock Your\nPOTENTIAL',
                        description: 'Earn achievements and build lasting habits as you grow deeper in your spiritual journey.',
                        theme: theme,
                      ),
                      _buildLanguageSelectionPage(theme),
                      _buildModernPage(
                        image: 'assets/onboarding/ready.webp',
                        title: 'You are\nREADY',
                        description: 'Join a community of seekers and saints. Your path to spiritual maturity starts now.',
                        theme: theme,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation (Indicator & Next)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Modern Pill Indicator
                      Row(
                        children: List.generate(_totalPages, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Premium Action Button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _totalPages - 1 ? 'GET STARTED' : 'NEXT',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPage({
    required String image,
    required String title,
    required String description,
    required ThemeData theme,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with premium shadow
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionPage(ThemeData theme) {
    final languageService = LanguageService();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHOOSE YOUR\nLANGUAGE',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: LanguageService.supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = LanguageService.supportedLanguages[index];
                final isSelected = languageService.currentLanguageCode == language.code;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        language.nativeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black, // Force black for maximum visibility
                        ),
                      ),
                      subtitle: Text(
                        language.name,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? theme.colorScheme.primary : Colors.grey[400],
                        size: 28,
                      ),
                      onTap: () async {
                        await languageService.changeLanguage(language.code);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

