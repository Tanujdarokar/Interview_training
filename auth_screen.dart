import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_build/screens/dashboard_screen.dart';
import '../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        await ref.read(authProvider.notifier).login(email, password);
      } else {
        await ref.read(authProvider.notifier).register(email, password);
      }
      
      if (!mounted) return;
      _navigateToDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) => ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final newPass = newPasswordController.text.trim();
                if (email.isEmpty || newPass.isEmpty) return;

                try {
                  await ref.read(authProvider.notifier).resetPassword(email, newPass);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset successful!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [Colors.black, Colors.indigo.shade900]
              : [Colors.indigo.shade800, Colors.indigo.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 12,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                          Icons.rocket_launch,
                          size: 64,
                          color: Colors.indigo,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .moveY(
                          begin: -10,
                          end: 10,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 16),
                    Text(
                          isLogin ? 'Welcome Back' : 'Join Interview Pro',
                          style: GoogleFonts.poppins(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .moveY(begin: -20, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      isLogin
                          ? 'Login to continue your journey'
                          : 'Start your practice today',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: Colors.indigo),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.indigo),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.indigo),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.indigo),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.indigo, fontSize: 13),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isLogin ? 'Login' : 'Create Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign Up"
                            : 'Already have an account? Login',
                        style: const TextStyle(color: Colors.indigo),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).loginAsGuest();
                        _navigateToDashboard();
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            ),
          ),
        ),
      ),
    );
  }
}
