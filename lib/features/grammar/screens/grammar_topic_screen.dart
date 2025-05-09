import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/models/grammar_topic.dart';

class GrammarTopicScreen extends ConsumerStatefulWidget {
  final String topicId;

  const GrammarTopicScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  ConsumerState<GrammarTopicScreen> createState() => _GrammarTopicScreenState();
}

class _GrammarTopicScreenState extends ConsumerState<GrammarTopicScreen> {
  @override
  void initState() {
    super.initState();
    // Load the grammar topic when the screen loads
    Future.microtask(() {
      ref
          .read(grammarControllerProvider.notifier)
          .loadGrammarTopic(widget.topicId);

      // Load and show an interstitial ad when the screen opens
      final adService = ref.read(adServiceProvider);
      adService.loadInterstitialAd().then((_) {
        adService.showInterstitialAd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = ref.watch(currentTopicProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic?.title ?? 'Dilbilgisi Konusu'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(grammarControllerProvider.notifier)
                                .loadGrammarTopic(widget.topicId);
                          },
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : topic == null
                  ? const Center(child: Text('Konu bulunamadı'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(topic.color
                                                  .replaceAll('#', '0xFF')))
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.book_outlined,
                                          color: Color(int.parse(topic.color
                                              .replaceAll('#', '0xFF'))),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          topic.title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    topic.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Grammar structure
                          if (topic.grammar_structure.isNotEmpty) ...[
                            const Text(
                              'Dilbilgisi Yapısı',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  topic.grammar_structure,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Examples
                          if (topic.examples.isNotEmpty) ...[
                            const Text(
                              'Örnekler',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: topic.examples.map((example) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '• $example',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Subtopics
                          if (topic.subtopics.isNotEmpty) ...[
                            const Text(
                              'Alt Konular',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...topic.subtopics.map((subtopic) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Load subtopic and navigate
                                    ref
                                        .read(
                                            grammarControllerProvider.notifier)
                                        .loadGrammarSubtopic(
                                            topic.id, subtopic.id);
                                    // Navigate to subtopic screen
                                    // This would be implemented in a real app
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                subtopic.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (subtopic
                                                  .description.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  subtopic.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
    );
  }
}
