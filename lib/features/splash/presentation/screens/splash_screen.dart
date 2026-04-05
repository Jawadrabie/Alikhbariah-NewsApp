import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surface,
              scheme.surface.withValues(alpha: 0.96),
              const Color(0xFFF7FAFC),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 148,
                          height: 148,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFE6EDF2),
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/brand/alikhbariah-icon-450.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'الإخبارية السورية',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
