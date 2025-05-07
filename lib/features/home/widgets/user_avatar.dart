import 'package:flutter/material.dart';
import '../../../core/utils/constants/colors.dart';

class UserAvatar extends StatelessWidget {
  final String? username;
  final double radius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    Key? key,
    this.username,
    this.radius = 20,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (username != null
            ? AppColors.primary.withOpacity(0.1)
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200));
    final txtColor = textColor ??
        (username != null
            ? AppColors.primary
            : (isDark ? Colors.white70 : Colors.black54));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: username != null && username!.isNotEmpty
              ? Text(
                  username![0].toUpperCase(),
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                  ),
                )
              : Icon(
                  Icons.person_outline_rounded,
                  color: txtColor,
                  size: radius,
                ),
        ),
      ),
    );
  }
}
