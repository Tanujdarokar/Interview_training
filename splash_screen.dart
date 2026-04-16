import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            authState.isAuthenticated ? const DashboardScreen() : const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.indigo.shade900,
      body: Stack(
        children: [
          // Background Gradient Glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 2.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ).animate()
                 .slideY(begin: 1, end: 0, duration: 800.ms, curve: Curves.easeOutBack)
                 .fadeIn()
                 .shimmer(delay: 1.seconds, duration: 1500.ms),

                const SizedBox(height: 32),

                // App Name
                Text(
                  "INTERVIEW PRO",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                ).animate()
                 .fadeIn(delay: 400.ms)
                 .slideY(begin: 0.5, end: 0),

                const SizedBox(height: 8),

                // Tactical Tagline
                Text(
                  "SYSTEM INITIALIZING...",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.indigo.shade200,
                  ),
                ).animate(onPlay: (c) => c.repeat())
                 .fadeIn(duration: 1.seconds)
                 .fadeOut(delay: 1.seconds, duration: 1.seconds),
              ],
            ),
          ),

          // Bottom Progress Bar
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ).animate().scaleX(duration: 3.seconds, begin: 0, end: 1),
                const SizedBox(height: 12),
                const Text(
                  "v2.0.4 | SECURE BOOT",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white24,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
