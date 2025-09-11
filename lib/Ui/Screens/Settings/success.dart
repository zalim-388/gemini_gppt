import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedSuccessDialog extends StatefulWidget {
  final bool isDarkMode;

  const AnimatedSuccessDialog({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  _AnimatedSuccessDialogState createState() => _AnimatedSuccessDialogState();
}

class _AnimatedSuccessDialogState extends State<AnimatedSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _dialogController;
  late AnimationController _iconController;
  late AnimationController _rippleController;
  late AnimationController _checkController;
  late AnimationController _titleController;
  late AnimationController _contentController;
  late AnimationController _badgeController;
  late AnimationController _buttonController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();

    // Initialize all animation controllers
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _starController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start overlay fade in
    _overlayController.forward();

    // Start dialog slide up
    _dialogController.forward();

    // Start progress bar animation (continuous)
    _progressController.repeat();

    // Start particles (continuous)
    _particleController.repeat();

    // Start star rotation (continuous)
    _starController.repeat();

    // Icon bounce animation (delay 200ms)
    await Future.delayed(const Duration(milliseconds: 200));
    _iconController.forward();

    // Title slide in (delay 300ms)
    await Future.delayed(const Duration(milliseconds: 100));
    _titleController.forward();

    // Content fade in (delay 400ms)
    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();

    // Ripple effect (delay 400ms)
    _rippleController.forward();

    // Badge slide in (delay 500ms)
    await Future.delayed(const Duration(milliseconds: 100));
    _badgeController.forward();

    // Check draw animation (delay 500ms)
    _checkController.forward();

    // Button slide up (delay 600ms)
    await Future.delayed(const Duration(milliseconds: 100));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _dialogController.dispose();
    _iconController.dispose();
    _rippleController.dispose();
    _checkController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _badgeController.dispose();
    _buttonController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _overlayController,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: AnimatedBuilder(
              animation: _dialogController,
              builder: (context, child) {
                return Transform.scale(
                  scale: Curves.easeOut.transform(_dialogController.value),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      50 *
                          (1 -
                              Curves.easeOut.transform(
                                _dialogController.value,
                              )),
                    ),
                    child: Opacity(
                      opacity: _dialogController.value,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 400.w,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color:
                              widget.isDarkMode
                                  ? const Color(0xFF2D2D2D)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 60,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Progress bar at top
                            // Positioned(
                            //   top: 0.2,
                            //   left: 0,
                            //   right: 0,
                            //   child: Padding(
                            //     padding: EdgeInsets.symmetric(horizontal: 10.w),
                            //     child: SizedBox(
                            //       height: 4.h,

                            //       child: ClipRRect(
                            //         borderRadius: BorderRadius.only(
                            //           topLeft: Radius.circular(100.r),
                            //           topRight: Radius.circular(100.r),
                            //         ),
                            //         child: AnimatedBuilder(
                            //           animation: _progressController,
                            //           builder: (context, child) {
                            //             return Container(
                            //               decoration: const BoxDecoration(
                            //                 gradient: LinearGradient(
                            //                   colors: [
                            //                     Color(0xFF4CAF50),
                            //                     Color(0xFF45a049),
                            //                   ],
                            //                 ),
                            //               ),
                            //               child: FractionallySizedBox(
                            //                 alignment: Alignment.centerLeft,
                            //                 widthFactor: 1.0,
                            //                 child: Transform.translate(
                            //                   offset: Offset(
                            //                     (2 * _progressController.value -
                            //                             1) *
                            //                         400.w,
                            //                     0,
                            //                   ),
                            //                   child: Container(
                            //                     width: 100.w,
                            //                     height: 4.h,
                            //                     decoration: BoxDecoration(
                            //                       color: Colors.white10,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             );
                            //           },
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            // Floating particles
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: AnimatedBuilder(
                                  animation: _particleController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: FloatingParticlesPainter(
                                        progress: _particleController.value,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Main content
                            Padding(
                              padding: EdgeInsets.all(30.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header with icon and title
                                  Row(
                                    children: [
                                      // Success icon with animations
                                      AnimatedBuilder(
                                        animation: _iconController,
                                        builder: (context, child) {
                                          final bounceValue =
                                              _iconController.value <= 0.5
                                                  ? _iconController.value * 2.4
                                                  : 1.2 -
                                                      (_iconController.value -
                                                              0.5) *
                                                          0.4;
                                          final rotationValue =
                                              _iconController.value *
                                              2 *
                                              3.14159;

                                          return Transform.scale(
                                            scale: bounceValue,
                                            child: Transform.rotate(
                                              angle: rotationValue,
                                              child: Container(
                                                width: 50.w,
                                                height: 50.w,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors:
                                                        widget.isDarkMode
                                                            ? [
                                                              const Color(
                                                                0xFF66bb6a,
                                                              ),
                                                              const Color(
                                                                0xFF4caf50,
                                                              ),
                                                            ]
                                                            : [
                                                              const Color(
                                                                0xFF4CAF50,
                                                              ),
                                                              const Color(
                                                                0xFF45a049,
                                                              ),
                                                            ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // Ripple effect
                                                    AnimatedBuilder(
                                                      animation:
                                                          _rippleController,
                                                      builder: (
                                                        context,
                                                        child,
                                                      ) {
                                                        return Positioned.fill(
                                                          child: Transform.scale(
                                                            scale:
                                                                _rippleController
                                                                    .value *
                                                                2,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.3 *
                                                                          (1 -
                                                                              _rippleController.value),
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      25.r,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    // Checkmark
                                                    Center(
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            _checkController,
                                                        builder: (
                                                          context,
                                                          child,
                                                        ) {
                                                          return CustomPaint(
                                                            size: const Size(
                                                              16,
                                                              16,
                                                            ),
                                                            painter: CheckmarkPainter(
                                                              progress:
                                                                  _checkController
                                                                      .value,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      SizedBox(width: 15.w),

                                      // Title animation
                                      Expanded(
                                        child: AnimatedBuilder(
                                          animation: _titleController,
                                          builder: (context, child) {
                                            return Transform.translate(
                                              offset: Offset(
                                                30 *
                                                    (1 -
                                                        Curves.easeOut
                                                            .transform(
                                                              _titleController
                                                                  .value,
                                                            )),
                                                0,
                                              ),
                                              child: Opacity(
                                                opacity: _titleController.value,
                                                child: Text(
                                                  'Welcome to Pro!',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        widget.isDarkMode
                                                            ? Colors.white
                                                            : const Color(
                                                              0xFF333333,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20.h),

                                  // Content animation
                                  AnimatedBuilder(
                                    animation: _contentController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          20 *
                                              (1 -
                                                  Curves.easeOut.transform(
                                                    _contentController.value,
                                                  )),
                                        ),
                                        child: Opacity(
                                          opacity: _contentController.value,
                                          child: Text(
                                            'Payment successful! You now have access to all premium features.',
                                            style: GoogleFonts.poppins(
                                              color:
                                                  widget.isDarkMode
                                                      ? const Color(0xFFCCCCCC)
                                                      : const Color(0xFF666666),
                                              fontSize: 14.sp,
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 25.h),

                                  // Premium badge animation
                                  AnimatedBuilder(
                                    animation: _badgeController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          -30 *
                                              (1 -
                                                  Curves.easeOut.transform(
                                                    _badgeController.value,
                                                  )),
                                          0,
                                        ),
                                        child: Opacity(
                                          opacity: _badgeController.value,
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFFFD700),
                                                  Color(0xFFFFB347),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFFFD700,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                AnimatedBuilder(
                                                  animation: _starController,
                                                  builder: (context, child) {
                                                    return Transform.rotate(
                                                      angle:
                                                          _starController
                                                              .value *
                                                          2 *
                                                          3.14159,
                                                      child: Icon(
                                                        Icons.star,
                                                        size: 20.sp,
                                                        color: const Color(
                                                          0xFF8B4513,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(
                                                  'Premium features unlocked',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(
                                                      0xFF8B4513,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 25.h),

                                  // Continue button animation
                                  AnimatedBuilder(
                                    animation: _buttonController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          30 *
                                              (1 -
                                                  Curves.easeOut.transform(
                                                    _buttonController.value,
                                                  )),
                                        ),
                                        child: Opacity(
                                          opacity: _buttonController.value,
                                          child: AnimatedContinueButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedContinueButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedContinueButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  _AnimatedContinueButtonState createState() => _AnimatedContinueButtonState();
}

class _AnimatedContinueButtonState extends State<AnimatedContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Start shimmer effect after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _shimmerController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..translate(0.0, _isPressed ? 0.0 : -2.0),
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF4CAF50,
                ).withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 15 : 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                // Shimmer effect
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned(
                      left: -100.w + (_shimmerController.value * 500.w),
                      top: 0,
                      child: Container(
                        width: 100.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Button text
                Center(
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Checkmark path points
    final point1 = Offset(center.dx - 4, center.dy);
    final point2 = Offset(center.dx - 1, center.dy + 3);
    final point3 = Offset(center.dx + 4, center.dy - 3);

    path.moveTo(point1.dx, point1.dy);

    if (progress <= 0.5) {
      // First half of checkmark
      final currentPoint = Offset.lerp(point1, point2, progress * 2)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Complete first half, animate second half
      path.lineTo(point2.dx, point2.dy);
      final secondProgress = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(point2, point3, secondProgress)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class FloatingParticlesPainter extends CustomPainter {
  final double progress;

  FloatingParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create 9 particles like in HTML
    final particles = [
      {'left': 0.1, 'delay': 0.0, 'color': const Color(0xFF4CAF50)},
      {'left': 0.2, 'delay': 0.5, 'color': const Color(0xFFFFD700)},
      {'left': 0.3, 'delay': 1.0, 'color': const Color(0xFF4CAF50)},
      {'left': 0.4, 'delay': 1.5, 'color': const Color(0xFFFFD700)},
      {'left': 0.5, 'delay': 2.0, 'color': const Color(0xFF4CAF50)},
      {'left': 0.6, 'delay': 0.3, 'color': const Color(0xFFFFD700)},
      {'left': 0.7, 'delay': 0.8, 'color': const Color(0xFF4CAF50)},
      {'left': 0.8, 'delay': 1.3, 'color': const Color(0xFFFFD700)},
      {'left': 0.9, 'delay': 1.8, 'color': const Color(0xFF4CAF50)},
    ];

    for (final particle in particles) {
      final xPos = (particle['left'] as double) * size.width;
      final delay = (particle['delay'] as double) / 3.0;
      final color = particle['color'] as Color;

      final adjustedProgress = (progress + delay) % 1.0;

      if (adjustedProgress > 0.1 && adjustedProgress < 0.9) {
        final yPos = size.height - (adjustedProgress * size.height * 1.2);
        final opacity = (1.0 - (adjustedProgress - 0.1) / 0.8).clamp(0.0, 1.0);
        final rotation = adjustedProgress * 2 * 3.14159;

        paint.color = color.withOpacity(opacity);

        canvas.save();
        canvas.translate(xPos, yPos);
        canvas.rotate(rotation);
        canvas.drawCircle(Offset.zero, 3, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
