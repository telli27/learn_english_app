import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback onFavoriteToggle;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _elevationAnimation;

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
        curve: Curves.easeInOutBack,
      ),
    )..addListener(() {
        setState(() {});
      });

    _elevationAnimation = Tween<double>(begin: 1, end: 15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    // Get available height to ensure we don't overflow
    final availableHeight = MediaQuery.of(context).size.height * 0.6;

    return Hero(
      tag: 'flashcard_${widget.flashcard.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleCard,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(pi * _animation.value),
              child: _animation.value < 0.5
                  ? // Front card (word)
                  Card(
                      elevation: _elevationAnimation.value,
                      shadowColor: isDark ? Colors.black : Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      color: cardColor,
                      child: Container(
                        height: availableHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          gradient: isDark
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF2E2E2E),
                                    const Color(0xFF242424),
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                        ),
                        child: Stack(
                          children: [
                            // Main content in scrollable container
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: availableHeight -
                                        48, // subtract padding
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Category badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade700
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.blue.shade700
                                                  .withOpacity(0.3),
                                              width: 1,
                                            )),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _getCategoryIcon(
                                                widget.flashcard.category),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.flashcard.category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Difficulty badge
                                      _buildDifficultyIndicator(
                                          widget.flashcard.difficulty),

                                      const SizedBox(height: 24),

                                      // Word image if available
                                      if (widget.flashcard.imageUrl.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          height:
                                              100, // Fixed height to prevent overflow
                                          width: 100, // Fixed width
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.black12
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              widget.flashcard.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 24),

                                      // Word text with shadow
                                      ShaderMask(
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            primaryColor,
                                            primaryColor.withBlue(min(
                                                255, primaryColor.blue + 40)),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: Text(
                                          widget.flashcard.word,
                                          style: const TextStyle(
                                            fontSize: 32, // Reduced font size
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      SizedBox(height: 36),

                                      // Tap to flip hint
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              size: 18,
                                              color: secondaryTextColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Çevirmek için dokunun',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Favorite button
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black26
                                      : Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.onFavoriteToggle,
                                    customBorder: const CircleBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        widget.flashcard.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: widget.flashcard.isFavorite
                                            ? Colors.red
                                            : secondaryTextColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : // Back card (translation and example)
                  Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: Card(
                        elevation: _elevationAnimation.value,
                        shadowColor: isDark ? Colors.black : Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color:
                                isDark ? Colors.white10 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        color: cardColor,
                        child: Container(
                          height: availableHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: -5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2E2E2E),
                                      const Color(0xFF242424),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                          ),
                          child: Stack(
                            children: [
                              // Main content in scrollable container
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: availableHeight -
                                          48, // subtract padding
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Translation
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (bounds) =>
                                              LinearGradient(
                                            colors: [
                                              primaryColor,
                                              primaryColor.withRed(min(
                                                  255, primaryColor.red + 40)),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                          child: Text(
                                            widget.flashcard.translation,
                                            style: const TextStyle(
                                              fontSize: 32, // Reduced font size
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Example
                                        if (widget.flashcard.example.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.black
                                                      .withOpacity(0.2)
                                                  : Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white10
                                                    : Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Example header
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color: primaryColor
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.format_quote,
                                                        size: 16,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Örnek',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Example text
                                                Text(
                                                  widget.flashcard.example,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontStyle: FontStyle.italic,
                                                    color: textColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),

                                                const SizedBox(height: 12),

                                                // Example translation
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? Colors.white
                                                            .withOpacity(0.05)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    widget.flashcard
                                                        .exampleTranslation,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: secondaryTextColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        SizedBox(height: 36),

                                        // Tap to flip hint
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.touch_app,
                                                size: 18,
                                                color: secondaryTextColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Çevirmek için dokunun',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Favorite button
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.black26
                                          : Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: widget.onFavoriteToggle,
                                        customBorder: const CircleBorder(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            widget.flashcard.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: widget.flashcard.isFavorite
                                                ? Colors.red
                                                : secondaryTextColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
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

  Widget _buildDifficultyIndicator(String difficulty) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (difficulty) {
      case 'Beginner':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        iconData = Icons.school;
        break;
      case 'Intermediate':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        iconData = Icons.trending_up;
        break;
      default: // Advanced
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        iconData = Icons.star;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icon(Icons.restaurant, size: 16, color: Colors.blue.shade700);
      case 'technology':
        return Icon(Icons.computer, size: 16, color: Colors.blue.shade700);
      case 'education':
        return Icon(Icons.school, size: 16, color: Colors.blue.shade700);
      case 'transportation':
        return Icon(Icons.directions_car,
            size: 16, color: Colors.blue.shade700);
      case 'home':
        return Icon(Icons.home, size: 16, color: Colors.blue.shade700);
      case 'abstract':
        return Icon(Icons.psychology, size: 16, color: Colors.blue.shade700);
      case 'finance':
        return Icon(Icons.attach_money, size: 16, color: Colors.blue.shade700);
      default:
        return Icon(Icons.category, size: 16, color: Colors.blue.shade700);
    }
  }
}
