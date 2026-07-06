import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashView extends StatefulWidget {
  final Widget nextScreen;

  const SplashView({super.key, required this.nextScreen});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // Master entrance animation
  late AnimationController _masterController;
  late Animation<double> _bgRevealAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _brandFadeAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _loaderFadeAnimation;

  // Continuous animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _particleController;
  late AnimationController _shimmerController;

  // Exit animation
  late AnimationController _exitController;
  late Animation<double> _exitFadeAnimation;
  late Animation<double> _exitScaleAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // ── Master Entrance (0.0 → 1.0 over 2800ms) ──
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _bgRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.12, 0.50, curve: Curves.elasticOut)),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );

    _brandFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.45, 0.70, curve: Curves.easeOut)),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.55, 0.78, curve: Curves.easeOut)),
    );

    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.65, 0.85, curve: Curves.easeOut)),
    );

    // ── Continuous Pulse ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Particle animation ──
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // ── Shimmer animation ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // ── Exit animation ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // Start the entrance
    _masterController.forward();

    // Schedule navigation after splash completes
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && !_navigated) {
        _navigated = true;
        _exitController.forward().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _masterController,
          _pulseController,
          _particleController,
          _shimmerController,
          _exitController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFadeAnimation,
            child: Transform.scale(
              scale: _exitScaleAnimation.value,
              child: Stack(
                children: [
                  // ── Deep Gradient Background ──
                  _buildBackground(size),

                  // ── Animated Particles ──
                  _buildParticles(size),

                  // ── Radial Glow Behind Logo ──
                  _buildRadialGlow(size),

                  // ── Main Content ──
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        _buildLogo(size),
                        SizedBox(height: size.height * 0.04),

                        // Brand Name
                        _buildBrandName(),
                        const SizedBox(height: 12),

                        // Tagline
                        _buildTagline(),
                        SizedBox(height: size.height * 0.08),

                        // Loading Indicator
                        _buildLoader(),
                      ],
                    ),
                  ),

                  // ── Bottom attribution ──
                  _buildBottomAttribution(size),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────── BACKGROUND ───────────────────────
  Widget _buildBackground(Size size) {
    return Opacity(
      opacity: _bgRevealAnimation.value.clamp(0.0, 1.0),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628), // Deep navy
              Color(0xFF0F2345), // Rich dark blue
              Color(0xFF162D56), // Mid blue
              Color(0xFF1A3A6B), // Brighter blue base
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _GridLinePainter(opacity: 0.04),
        ),
      ),
    );
  }

  // ─────────────────────── PARTICLES ───────────────────────
  Widget _buildParticles(Size size) {
    return Opacity(
      opacity: (_bgRevealAnimation.value * 0.8).clamp(0.0, 0.8),
      child: CustomPaint(
        size: size,
        painter: _FloatingParticlePainter(
          progress: _particleController.value,
          particleCount: 35,
        ),
      ),
    );
  }

  // ─────────────────────── RADIAL GLOW ───────────────────────
  Widget _buildRadialGlow(Size size) {
    final glowOpacity = (_logoGlowAnimation.value * 0.5).clamp(0.0, 0.5);
    return Center(
      child: Container(
        width: size.width * 0.8,
        height: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF3B82F6).withOpacity(glowOpacity * 0.6),
              const Color(0xFF6366F1).withOpacity(glowOpacity * 0.3),
              const Color(0xFF0EA5E9).withOpacity(glowOpacity * 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── LOGO ───────────────────────
  Widget _buildLogo(Size size) {
    final scale = _logoScaleAnimation.value.clamp(0.0, 1.2);
    final pulseScale = _pulseAnimation.value;
    final logoSize = size.width * 0.30;

    return Transform.scale(
      scale: scale * pulseScale,
      child: Container(
        width: logoSize,
        height: logoSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(logoSize * 0.26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.5 * _logoGlowAnimation.value),
              blurRadius: 40,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3 * _logoGlowAnimation.value),
              blurRadius: 80,
              spreadRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(logoSize * 0.26),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ─────────────────────── BRAND NAME ───────────────────────
  Widget _buildBrandName() {
    final opacity = _brandFadeAnimation.value.clamp(0.0, 1.0);
    final slideOffset = (1.0 - _brandFadeAnimation.value) * 30;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, slideOffset),
        child: Column(
          children: [
            // Brand name with shimmer
            ShaderMask(
              shaderCallback: (bounds) {
                final shimmerProgress = _shimmerController.value;
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Colors.white,
                    Color(0xFF93C5FD),
                    Colors.white,
                    Color(0xFFA5B4FC),
                    Colors.white,
                  ],
                  stops: [
                    (shimmerProgress - 0.3).clamp(0.0, 1.0),
                    (shimmerProgress - 0.1).clamp(0.0, 1.0),
                    shimmerProgress,
                    (shimmerProgress + 0.1).clamp(0.0, 1.0),
                    (shimmerProgress + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'MAGADIGE',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── TAGLINE ───────────────────────
  Widget _buildTagline() {
    final opacity = _taglineFadeAnimation.value.clamp(0.0, 1.0);
    final slideOffset = (1.0 - _taglineFadeAnimation.value) * 20;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, slideOffset),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Text(
            'Climb Your Milestones ✦',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF93C5FD),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── LOADER ───────────────────────
  Widget _buildLoader() {
    final opacity = _loaderFadeAnimation.value.clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 180,
        child: Column(
          children: [
            // Custom animated progress bar
            Container(
              height: 3,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.08),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Animated fill
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          final progress = _shimmerController.value;
                          return Container(
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF6366F1),
                                  Color(0xFF0EA5E9),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing your workspace...',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withOpacity(0.35),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── BOTTOM ATTRIBUTION ───────────────────────
  Widget _buildBottomAttribution(Size size) {
    final opacity = _loaderFadeAnimation.value.clamp(0.0, 1.0);
    return Positioned(
      bottom: size.height * 0.05,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity * 0.5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Task Management Reimagined',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ════════════════════════════════════════════════════════════

/// Subtle grid lines on the background
class _GridLinePainter extends CustomPainter {
  final double opacity;
  _GridLinePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Diagonal accent lines
    final accentPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(opacity * 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width * 0.4, 0),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height),
      Offset(size.width, size.height * 0.7),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating particles with gentle movement
class _FloatingParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;
  final List<_Particle> _particles;

  _FloatingParticlePainter({
    required this.progress,
    required this.particleCount,
  }) : _particles = List.generate(particleCount, (i) => _Particle(i, particleCount));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      final adjustedProgress = (progress + particle.phaseOffset) % 1.0;

      // Gentle floating motion
      final x = particle.baseX * size.width +
          sin(adjustedProgress * 2 * pi + particle.angleOffset) * particle.wanderRadius * size.width;
      final y = particle.baseY * size.height +
          cos(adjustedProgress * 2 * pi * particle.speedMultiplier + particle.angleOffset) *
              particle.wanderRadius *
              size.height;

      // Pulsing opacity
      final alpha = (particle.baseAlpha *
              (0.5 + 0.5 * sin(adjustedProgress * 2 * pi * 1.5 + particle.phaseOffset * 6)))
          .clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withOpacity(alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.8);

      canvas.drawCircle(Offset(x, y), particle.size, paint);

      // Inner bright core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.6);
      canvas.drawCircle(Offset(x, y), particle.size * 0.3, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  final double baseX;
  final double baseY;
  final double size;
  final double baseAlpha;
  final double phaseOffset;
  final double angleOffset;
  final double wanderRadius;
  final double speedMultiplier;
  final Color color;

  _Particle(int index, int total)
      : baseX = _seededRandom(index * 7 + 1),
        baseY = _seededRandom(index * 13 + 3),
        size = 1.2 + _seededRandom(index * 17 + 5) * 2.5,
        baseAlpha = 0.15 + _seededRandom(index * 23 + 7) * 0.35,
        phaseOffset = _seededRandom(index * 31 + 11),
        angleOffset = _seededRandom(index * 37 + 13) * 2 * pi,
        wanderRadius = 0.01 + _seededRandom(index * 43 + 17) * 0.03,
        speedMultiplier = 0.5 + _seededRandom(index * 47 + 19) * 1.5,
        color = [
          const Color(0xFF3B82F6), // Blue
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF0EA5E9), // Sky blue
          const Color(0xFF22D3EE), // Cyan
          const Color(0xFF818CF8), // Light indigo
        ][index % 5];

  static double _seededRandom(int seed) {
    return ((sin(seed.toDouble()) * 43758.5453) % 1.0).abs();
  }
}
