import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isPressed;
  final Color backgroundColor;
  final double depth;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.isPressed = false,
    this.backgroundColor = const Color(0xFF2A2D32),
    this.depth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                  spreadRadius: -2,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF1F2125), // Dark shadow (bottom right)
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color(0xFF35393F), // Light highlight (top left)
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}
