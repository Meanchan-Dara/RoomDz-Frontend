import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 2026 Modern Button Content with Animated Bouncing Wave Dots
/// Replaces plain CircularProgressIndicator with an elegant, responsive title + dots animation.
class ModernButtonContent extends StatelessWidget {
  final bool isLoading;
  final String text;
  final String? loadingText;
  final IconData? icon;
  final Widget? iconWidget;
  final TextStyle? textStyle;
  final Color textColor;
  final double dotSize;
  final double dotSpacing;
  final double iconSize;

  const ModernButtonContent({
    super.key,
    required this.isLoading,
    required this.text,
    this.loadingText,
    this.icon,
    this.iconWidget,
    this.textStyle,
    this.textColor = Colors.white,
    this.dotSize = 4.5,
    this.dotSpacing = 3.5,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        textStyle ??
        GoogleFonts.battambang(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        );

    final displayLoadingText = loadingText ?? text;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.12),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isLoading
          ? Row(
              key: const ValueKey('loading_state'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(displayLoadingText, style: effectiveStyle),
                const SizedBox(width: 5),
                AnimatedThreeDots(
                  color: textColor,
                  size: dotSize,
                  spacing: dotSpacing,
                ),
              ],
            )
          : Row(
              key: const ValueKey('idle_state'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconWidget != null) ...[
                  iconWidget!,
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, size: iconSize, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(text, style: effectiveStyle),
              ],
            ),
    );
  }
}

/// 3 Sequential Bouncing / Pulsing Wave Dots (Linear / Apple 2026 Micro-animation)
class AnimatedThreeDots extends StatefulWidget {
  final Color color;
  final double size;
  final double spacing;

  const AnimatedThreeDots({
    super.key,
    required this.color,
    this.size = 4.5,
    this.spacing = 3.5,
  });

  @override
  State<AnimatedThreeDots> createState() => _AnimatedThreeDotsState();
}

class _AnimatedThreeDotsState extends State<AnimatedThreeDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    final delay = index * 0.18;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = (_controller.value - delay);
        if (t < 0) t += 1.0;

        double bounce = 0.0;
        double opacity = 0.35;
        double scale = 0.85;

        if (t < 0.5) {
          final sine = math.sin(t / 0.5 * math.pi);
          bounce = -4.5 * sine;
          opacity = 0.35 + (0.65 * sine);
          scale = 0.85 + (0.35 * sine);
        }

        return Transform.translate(
          offset: Offset(0, bounce),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity.clamp(0.2, 1.0),
              child: Container(
                width: widget.size,
                height: widget.size,
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_buildDot(0), _buildDot(1), _buildDot(2)],
      ),
    );
  }
}
