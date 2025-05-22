import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onFavoriteToggle;
  final Color? accentColor;
  final Color? backgroundColor;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    this.onFavoriteToggle,
    this.accentColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuad,
      ),
    )..addListener(() {
        setState(() {});
      });

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFlipped) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Define custom color scheme
    final primaryColor = widget.accentColor ?? const Color(0xFF5E73E1);
    final secondaryColor = const Color(0xFFED6B5B);
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF303952) : const Color(0xFFF7F9FC));
    final textColor = isDark ? Colors.white : const Color(0xFF2C3A47);
    final subtleColor =
        isDark ? const Color(0xFF8395A7) : const Color(0xFF8395A7);

    // Card dimensions
    final cardHeight = size.height * 0.42;
    final cardWidth = size.width * 0.88;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _toggleCard,
          child: Container(
            height: cardHeight,
            width: cardWidth,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(pi * _animation.value),
              child: _animation.value < 0.5
                  ? _buildFrontCard(isDark, primaryColor, secondaryColor,
                      bgColor, textColor, subtleColor)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBackCard(isDark, primaryColor,
                          secondaryColor, bgColor, textColor, subtleColor),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(bool isDark, Color primaryColor, Color secondaryColor,
      Color bgColor, Color textColor, Color subtleColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(
                  primaryColor: primaryColor.withOpacity(0.05),
                  secondaryColor: secondaryColor.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                // Top bar with category and level
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: subtleColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getCategoryIcon(
                                widget.flashcard.category, primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              widget.flashcard.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Level badge
                      _buildDifficultyBadge(
                          widget.flashcard.difficulty, secondaryColor),
                    ],
                  ),
                ),

                // Word content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        if (widget.flashcard.imageUrl.isNotEmpty)
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.flashcard.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image,
                                  color: secondaryColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),

                        // Word
                        Text(
                          widget.flashcard.word,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom instruction
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: subtleColor.withOpacity(0.05),
                    border: Border(
                      top: BorderSide(
                        color: subtleColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: subtleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Çevirmek için dokunun',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subtleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(bool isDark, Color primaryColor, Color secondaryColor,
      Color bgColor, Color textColor, Color subtleColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(
                  primaryColor: secondaryColor.withOpacity(0.05),
                  secondaryColor: primaryColor.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                // Translation header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: subtleColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.flashcard.translation,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Example content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: widget.flashcard.example.isNotEmpty
                        ? Column(
                            children: [
                              // Example label
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'ÖRNEK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: primaryColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Example text
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black12 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: subtleColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.flashcard.example,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Example translation
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: subtleColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: subtleColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.flashcard.exampleTranslation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: subtleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              'Bu kelime için örnek bulunmamaktadır',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtleColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),

                // Bottom instruction
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: subtleColor.withOpacity(0.05),
                    border: Border(
                      top: BorderSide(
                        color: subtleColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: subtleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Çevirmek için dokunun',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subtleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty, Color secondaryColor) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (difficulty) {
      case 'Beginner':
        backgroundColor = const Color(0xFF68D391).withOpacity(0.1);
        textColor = const Color(0xFF68D391);
        iconData = Icons.school;
        break;
      case 'Intermediate':
        backgroundColor = const Color(0xFFF6AD55).withOpacity(0.1);
        textColor = const Color(0xFFF6AD55);
        iconData = Icons.trending_up;
        break;
      default: // Advanced
        backgroundColor = secondaryColor.withOpacity(0.1);
        textColor = secondaryColor;
        iconData = Icons.star;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category, Color color) {
    final Map<String, IconData> categoryIcons = {
      'food': Icons.restaurant,
      'technology': Icons.computer,
      'education': Icons.school,
      'transportation': Icons.directions_car,
      'home': Icons.home,
      'abstract': Icons.psychology,
      'finance': Icons.attach_money,
      'entertainment': Icons.movie,
      'health': Icons.favorite,
      'shopping': Icons.shopping_bag,
    };

    final IconData iconData =
        categoryIcons[category.toLowerCase()] ?? Icons.category;
    return Icon(iconData, size: 14, color: color);
  }
}

// Custom painter for background pattern
class PatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  PatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    final spacing = 20.0;

    // Draw dots pattern
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x / spacing).floor() % 2 == 0 && (y / spacing).floor() % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }

    // Draw decorative circles
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.2), 40, circlePaint);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.85), 30, circlePaint);
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
