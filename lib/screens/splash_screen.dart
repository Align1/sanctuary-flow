import 'package:flutter/material.dart';
import 'package:rooted/screens/onboarding_screen.dart';
import 'package:rooted/screens/home_page.dart';
import 'package:rooted/screens/auth_screen.dart';
import 'package:rooted/services/onboarding_service.dart';
import 'package:rooted/services/supabase_service.dart';

/// Splash screen shown during app initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for animation to complete (reduced for snappier feel)
    await Future.delayed(const Duration(milliseconds: 1200));

    // Check if onboarding is needed
    final hasOnboarded = await OnboardingService.hasCompletedOnboarding();
    final supabase = SupabaseService();
    final isAuthenticated = supabase.isAuthenticated;

    if (mounted) {
      Widget nextScreen;
      if (!hasOnboarded) {
        nextScreen = const OnboardingScreen();
      } else if (isAuthenticated && !supabase.isGuest) {
        nextScreen = const HomePage();
      } else {
        nextScreen = const AuthScreen();
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Premium Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          
          // Subtle Texture/Pattern simulation
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/icon/app_icon.png', // Using the icon as a subtle pattern
                repeat: ImageRepeat.repeat,
                scale: 5,
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glassmorphism Logo Container
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Elegant App Name
                    Text(
                      'ROOTED',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tagline with secondary color
                    Text(
                      'YOUR SPIRITUAL JOURNEY',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Minimalist loading
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Version info at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'VERSION 1.0.0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

