import 'package:flutter/material.dart';

/// A reusable card widget for displaying educational content like rules, examples, etc.
class ContentCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  const ContentCard({
    Key? key,
    required this.title,
    required this.content,
    required this.color,
    this.actions,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    this.elevated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),

          // Content section
          if (leading != null)
            Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading!,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF303030),
                        height: 1.6,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            )
          else
            Padding(
              padding: padding,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF303030),
                  height: 1.6,
                ),
              ),
            ),

          // Optional action buttons at the bottom
          if (actions != null && actions!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
