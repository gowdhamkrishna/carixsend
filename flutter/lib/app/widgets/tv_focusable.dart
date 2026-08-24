import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable TV D-Pad focusable card wrapper.
/// Optimized for low-spec Android TV hardware (no expensive blur/shadow filters)
/// and touch devices (mobile).
class TVFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool autofocus;
  final Color? focusBorderColor;
  final Color? focusBackgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool focusable;

  const TVFocusableCard({
    super.key,
    required this.child,
    this.onTap,
    this.autofocus = false,
    this.focusBorderColor,
    this.focusBackgroundColor,
    this.borderRadius,
    this.margin,
    this.padding,
    this.focusable = true,
  });

  @override
  State<TVFocusableCard> createState() => _TVFocusableCardState();
}

class _TVFocusableCardState extends State<TVFocusableCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final borderColor = widget.focusBorderColor ?? theme.colorScheme.primary;

    if (!widget.focusable) {
      return _buildContainer(effectiveBorderRadius, borderColor);
    }

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        if (mounted) {
          setState(() {
            _isFocused = focused;
          });
        }
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: _buildContainer(effectiveBorderRadius, borderColor),
    );
  }

  Widget _buildContainer(BorderRadius effectiveBorderRadius, Color borderColor) {
    return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          color: const Color(0xFF2C2C2C), // Dark Neumorphic base
          border: _isFocused
              ? Border.all(color: borderColor, width: 2.0)
              : null,
          boxShadow: _isFocused
              ? null // Pressed / Focused state removes outer shadow (could add inner shadow or rely on border)
              : const [
                  BoxShadow(
                    color: Color(0xFF3B3B3B),
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Color(0xFF1D1D1D),
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: effectiveBorderRadius,
          child: InkWell(
            onTap: widget.focusable ? widget.onTap : null,
            borderRadius: effectiveBorderRadius,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      );
  }
}

/// TV-friendly focusable button for remote control and mobile tap.
class TVButton extends StatefulWidget {
  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final bool autofocus;
  final Color? color;
  final bool isSecondary;

  const TVButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.autofocus = false,
    this.color,
    this.isSecondary = false,
  });

  @override
  State<TVButton> createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.color ?? theme.colorScheme.primary;

    final fgColor = widget.isSecondary
        ? baseColor
        : (_isFocused ? baseColor : Colors.white);

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        if (mounted) {
          setState(() {
            _isFocused = focused;
          });
        }
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF2C2C2C),
          border: _isFocused
              ? Border.all(color: baseColor, width: 2.0)
              : null,
          boxShadow: (widget.onPressed == null || _isFocused)
              ? null
              : const [
                  BoxShadow(
                    color: Color(0xFF3B3B3B),
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Color(0xFF1D1D1D),
                    offset: Offset(3, 3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: 22),
                    child: widget.icon,
                  ),
                  const SizedBox(width: 10),
                  DefaultTextStyle(
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: widget.label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// D-Pad focusable choice chip for device selection.
class TVChoiceChip extends StatefulWidget {
  final Widget label;
  final Widget? avatar;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool autofocus;

  const TVChoiceChip({
    super.key,
    required this.label,
    this.avatar,
    required this.selected,
    this.onSelected,
    this.autofocus = false,
  });

  @override
  State<TVChoiceChip> createState() => _TVChoiceChipState();
}

class _TVChoiceChipState extends State<TVChoiceChip> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final fgColor = widget.selected ? primary : Colors.white;

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        if (mounted) {
          setState(() {
            _isFocused = focused;
          });
        }
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onSelected?.call(!widget.selected);
            return null;
          },
        ),
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF2C2C2C),
          border: _isFocused
              ? Border.all(color: primary, width: 2.0)
              : null,
          boxShadow: widget.selected
              ? null // No shadow for selected state (looks pressed)
              : const [
                  BoxShadow(
                    color: Color(0xFF3B3B3B),
                    offset: Offset(-3, -3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Color(0xFF1D1D1D),
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => widget.onSelected?.call(!widget.selected),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.avatar != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        size: 18,
                        color: widget.selected ? primary : Colors.grey[400],
                      ),
                      child: widget.avatar!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: fgColor,
                      fontWeight: widget.selected || _isFocused ? FontWeight.bold : FontWeight.normal,
                    ),
                    child: widget.label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

