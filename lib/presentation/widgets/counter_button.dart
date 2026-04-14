import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zikermate/core/theme/app_theme.dart';

/// Large circular tap-to-count button with scale animation and haptic feedback.
class CounterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isComplete;

  const CounterButton({
    super.key,
    required this.onPressed,
    this.isComplete = false,
  });

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: widget.isComplete
                  ? [AppTheme.accentGold, const Color(0xFFF9A825)]
                  : [AppTheme.primaryTeal, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isComplete
                        ? AppTheme.accentGold
                        : AppTheme.primaryTeal)
                    .withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: (widget.isComplete
                        ? AppTheme.accentGold
                        : AppTheme.primaryTeal)
                    .withValues(alpha: 0.15),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.isComplete ? Icons.check_rounded : Icons.touch_app_rounded,
              size: 52,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}
