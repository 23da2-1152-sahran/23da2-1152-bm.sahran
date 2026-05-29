import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();

    // Wait for auth initialization AND minimum animation duration
    _navigateAfterInit();
  }

  /// Navigate to appropriate screen after auth is initialized
  /// Ensures at least 1.2 seconds of animation is shown
  Future<void> _navigateAfterInit() async {
    final auth = context.read<AuthProvider>();
    
    // Wait for auth initialization with a timeout
    int waitTime = 0;
    while (!auth.isInitialized && waitTime < 5000) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitTime += 100;
    }
    
    // Wait for animation to complete (minimum 1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      // Get fresh auth state
      final destination = auth.isAuthenticated ? '/home' : '/login';
      
      // Use pushReplacementNamed for cleaner navigation
      if (mounted) {
        Navigator.pushReplacementNamed(context, destination);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Decorative corner borders
          Positioned(
            top: 80,
            left: 80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.04), width: 1),
                  left: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.04), width: 1),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.04), width: 1),
                  right: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.04), width: 1),
                ),
              ),
            ),
          ),
          // Gold blur top-right
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Gold blur bottom-left
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Gold gradient top line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.accent.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SENIOR',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 9.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'THE EDITORIAL BOUTIQUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 6.0,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 120,
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.accent.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom icons
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeatureItem(icon: Icons.diamond_outlined, label: 'CURATED'),
                  SizedBox(width: 40),
                  _FeatureItem(
                      icon: Icons.auto_awesome_outlined, label: 'EXCLUSIVE'),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeatureItem(icon: Icons.brush_outlined, label: 'TAILORED'),
                  SizedBox(width: 40),
                  _FeatureItem(icon: Icons.language_outlined, label: 'GLOBAL'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppTheme.textPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
