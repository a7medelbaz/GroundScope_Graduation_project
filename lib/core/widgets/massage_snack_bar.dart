
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_text_styles.dart';
import '../utils/extensions/context_ext.dart';

class MessageSnackBar extends StatefulWidget {
  const MessageSnackBar({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final SnackBarType type;
  final VoidCallback onDismiss;

  @override
  State<MessageSnackBar> createState() => _MessageSnackBarState();
}

class _MessageSnackBarState extends State<MessageSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    final seconds = widget.type == SnackBarType.error ? 4 : 3;
    Future.delayed(Duration(seconds: seconds), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.type == SnackBarType.error;

    final Color bgColor = isError
        ? context.colorScheme.error
        : const Color(0xFF22C55E);

    final IconData icon = isError
        ? Icons.error_rounded
        : Icons.check_circle_rounded;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 32.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withValues(alpha: .4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 24.r),
                        SizedBox(width: 12.w),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: AppTextStyles.font14SemiBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
