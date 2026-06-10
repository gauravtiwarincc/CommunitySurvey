import 'package:flutter/material.dart';

class GlowingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final double borderRadius;
  final Color? glowColor;

  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.borderRadius = 16,
    this.glowColor,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null;
    final primary = widget.glowColor ?? theme.colorScheme.primary;

    final defaultGradient = LinearGradient(
      colors: [
        primary,
        theme.colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: isEnabled ? (widget.gradient ?? defaultGradient) : null,
            color: isEnabled ? null : Colors.white.withOpacity(0.06),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: DefaultTextStyle(
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? Colors.white : Colors.white24,
                    ) ??
                    const TextStyle(),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
