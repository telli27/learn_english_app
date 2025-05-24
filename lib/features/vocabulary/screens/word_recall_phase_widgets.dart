import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controllers/word_recall_game_controller.dart';
import '../models/word_models.dart';
import '../themes/game_theme.dart';

/// Study Phase Widget - Modern and clean design
class StudyPhaseWidget extends StatelessWidget {
  final WordRecallGameController controller;
  final GameTheme gameTheme;
  final ColorScheme colorScheme;
  final VoidCallback onProceedToRecall;

  const StudyPhaseWidget({
    super.key,
    required this.controller,
    required this.gameTheme,
    required this.colorScheme,
    required this.onProceedToRecall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInstructionCard(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildWordsList(),
        ),
        const SizedBox(height: 20),
        _buildProceedButton(),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gameTheme.primaryColor.withOpacity(0.1),
            gameTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gameTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gameTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelimeleri Ezberleyin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu kelimeleri çalışın. Sonra hatırlamanız istenecek.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.studyWords.length,
      itemBuilder: (context, index) {
        final word = controller.studyWords[index];
        return _ModernWordCard(
          word: word,
          gameTheme: gameTheme,
          colorScheme: colorScheme,
          index: index,
        );
      },
    );
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gameTheme.primaryColor,
            gameTheme.accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gameTheme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onProceedToRecall,
          child: const Center(
            child: Text(
              'HATIRLAMA AŞAMASINA GEÇ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Recall Phase Widget - Interactive and engaging
class RecallPhaseWidget extends StatelessWidget {
  final WordRecallGameController controller;
  final GameTheme gameTheme;
  final ColorScheme colorScheme;
  final RecallWord? currentWord;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final Animation<double> pulseAnimation;
  final VoidCallback onCheckAnswer;
  final VoidCallback onSkipWord;

  const RecallPhaseWidget({
    super.key,
    required this.controller,
    required this.gameTheme,
    required this.colorScheme,
    required this.currentWord,
    required this.inputController,
    required this.inputFocusNode,
    required this.pulseAnimation,
    required this.onCheckAnswer,
    required this.onSkipWord,
  });

  @override
  Widget build(BuildContext context) {
    if (currentWord == null) {
      return _buildLoadingState();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWordDisplay(),
        const SizedBox(height: 40),
        _buildHintButton(),
        const SizedBox(height: 40),
        _buildInputField(),
        const SizedBox(height: 30),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(gameTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Sonraki kelime yükleniyor...',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordDisplay() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  gameTheme.primaryColor.withOpacity(0.2),
                  gameTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: gameTheme.primaryColor.withOpacity(0.5),
                width: 3,
              ),
            ),
            child: Text(
              currentWord!.english,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: gameTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHintButton() {
    if (currentWord!.hint.isEmpty) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () {
        Fluttertoast.showToast(
          msg: "💡 ${currentWord!.hint}",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
        );
      },
      icon: Icon(
        Icons.lightbulb_outline,
        color: Colors.amber,
        size: 24,
      ),
      label: Text(
        'İpucu Göster',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gameTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: inputController,
        focusNode: inputFocusNode,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Türkçe karşılığını yazın...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 18,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: gameTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: gameTheme.primaryColor,
              width: 2,
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gameTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onCheckAnswer,
            ),
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onCheckAnswer(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onSkipWord,
          icon: const Icon(Icons.skip_next),
          label: const Text('Atla'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface.withOpacity(0.7),
            side: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

/// Review Phase Widget - Results and analysis
class ReviewPhaseWidget extends StatelessWidget {
  final WordRecallGameController controller;
  final GameTheme gameTheme;
  final ColorScheme colorScheme;
  final VoidCallback onComplete;

  const ReviewPhaseWidget({
    super.key,
    required this.controller,
    required this.gameTheme,
    required this.colorScheme,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildResultsCard(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildWordReview(),
        ),
        const SizedBox(height: 20),
        _buildCompleteButton(),
      ],
    );
  }

  Widget _buildResultsCard() {
    final accuracy = (controller.recallAccuracy * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gameTheme.primaryColor.withOpacity(0.1),
            gameTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gameTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Alıştırma Sonuçları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Doğru',
                value: '${controller.correctlyRecalledWords.length}',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                label: 'Yanlış',
                value: '${controller.incorrectlyRecalledWords.length}',
                color: Colors.red,
              ),
              _buildStatItem(
                icon: Icons.analytics,
                label: 'Başarı',
                value: '%$accuracy',
                color: gameTheme.primaryColor,
              ),
              _buildStatItem(
                icon: Icons.emoji_events,
                label: 'Puan',
                value: '${controller.score}',
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWordReview() {
    return ListView(
      children: [
        if (controller.correctlyRecalledWords.isNotEmpty) ...[
          _buildSectionHeader('Doğru Kelimeler', Colors.green),
          ...controller.correctlyRecalledWords.map(
            (word) => _WordReviewCard(
              word: word,
              isCorrect: true,
              colorScheme: colorScheme,
            ),
          ),
        ],
        if (controller.incorrectlyRecalledWords.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Yanlış Kelimeler', Colors.red),
          ...controller.incorrectlyRecalledWords.map(
            (word) => _WordReviewCard(
              word: word,
              isCorrect: false,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gameTheme.primaryColor, gameTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gameTheme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onComplete,
          child: const Center(
            child: Text(
              'ALIŞTIRMAYI TAMAMLA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Complete Phase Widget - Celebration and next steps
class CompletePhaseWidget extends StatelessWidget {
  final WordRecallGameController controller;
  final GameTheme gameTheme;
  final ColorScheme colorScheme;
  final VoidCallback onNextAction;

  const CompletePhaseWidget({
    super.key,
    required this.controller,
    required this.gameTheme,
    required this.colorScheme,
    required this.onNextAction,
  });

  @override
  Widget build(BuildContext context) {
    final isLastExercise = controller.currentExercise.orderInLevel ==
        controller.currentLevel.exercises.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSuccessIcon(isLastExercise),
        const SizedBox(height: 30),
        _buildCompletionMessage(isLastExercise),
        const SizedBox(height: 30),
        _buildScoreCard(),
        const SizedBox(height: 40),
        _buildActionButtons(isLastExercise),
      ],
    );
  }

  Widget _buildSuccessIcon(bool isLastExercise) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            gameTheme.primaryColor.withOpacity(0.2),
            gameTheme.primaryColor.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLastExercise ? Icons.emoji_events : Icons.check_circle,
        size: 80,
        color: gameTheme.primaryColor,
      ),
    );
  }

  Widget _buildCompletionMessage(bool isLastExercise) {
    return Text(
      isLastExercise
          ? 'Seviye ${controller.currentLevel.id} Tamamlandı! 🎉'
          : 'Alıştırma ${controller.currentExercise.orderInLevel} Tamamlandı! ✨',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gameTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildScoreRow('Doğru Kelimeler',
              '${controller.correctlyRecalledWords.length}/${controller.wordCount}'),
          const SizedBox(height: 12),
          _buildScoreRow(
              'Başarı Oranı', '%${(controller.recallAccuracy * 100).round()}'),
          const SizedBox(height: 12),
          _buildScoreRow('Alıştırma Puanı', '${controller.score}'),
          if (controller.currentExercise.orderInLevel ==
              controller.currentLevel.exercises.length) ...[
            const Divider(height: 24),
            _buildScoreRow(
                'Toplam Seviye Puanı', '${controller.totalLevelScore}',
                isHighlight: true),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? gameTheme.primaryColor : colorScheme.onSurface,
            fontSize: isHighlight ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLastExercise) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Ana Menü'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onNextAction,
              icon: Icon(
                isLastExercise
                    ? (controller.isGameCompleted
                        ? Icons.celebration
                        : Icons.arrow_forward)
                    : Icons.skip_next,
              ),
              label: Text(
                isLastExercise
                    ? (controller.isGameCompleted ? 'Bitir' : 'Sonraki Seviye')
                    : 'Sonraki Alıştırma',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern Word Card for study phase
class _ModernWordCard extends StatelessWidget {
  final RecallWord word;
  final GameTheme gameTheme;
  final ColorScheme colorScheme;
  final int index;

  const _ModernWordCard({
    required this.word,
    required this.gameTheme,
    required this.colorScheme,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gameTheme.primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: gameTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gameTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: gameTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.turkish,
                    style: TextStyle(
                      fontSize: 16,
                      color: gameTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (word.hint.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      word.hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Word Review Card for review phase
class _WordReviewCard extends StatelessWidget {
  final RecallWord word;
  final bool isCorrect;
  final ColorScheme colorScheme;

  const _WordReviewCard({
    required this.word,
    required this.isCorrect,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.english,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  word.turkish,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
