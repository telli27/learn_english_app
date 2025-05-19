import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import 'dart:math';

class CustomCardForm extends ConsumerStatefulWidget {
  final Flashcard? initialFlashcard;
  final Function(Flashcard) onSave;

  const CustomCardForm({
    Key? key,
    this.initialFlashcard,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<CustomCardForm> createState() => _CustomCardFormState();
}

class _CustomCardFormState extends ConsumerState<CustomCardForm> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleTranslationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _synonymsController = TextEditingController();
  final _antonymsController = TextEditingController();

  // Form values
  String _selectedDifficulty = 'Beginner';
  String _selectedUsageFrequency = 'Common';

  // Difficulty options
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  // Usage frequency options
  final List<String> _usageFrequencies = ['Common', 'Uncommon', 'Rare'];

  @override
  void initState() {
    super.initState();
    if (widget.initialFlashcard != null) {
      _wordController.text = widget.initialFlashcard!.word;
      _translationController.text = widget.initialFlashcard!.translation;
      _exampleController.text = widget.initialFlashcard!.example;
      _exampleTranslationController.text =
          widget.initialFlashcard!.exampleTranslation;
      _imageUrlController.text = widget.initialFlashcard!.imageUrl;
      _categoryController.text = widget.initialFlashcard!.category;
      _selectedDifficulty = widget.initialFlashcard!.difficulty;
      _pronunciationController.text = widget.initialFlashcard!.pronunciation;
      _audioUrlController.text = widget.initialFlashcard!.audioUrl;
      _synonymsController.text = widget.initialFlashcard!.synonyms.join(', ');
      _antonymsController.text = widget.initialFlashcard!.antonyms.join(', ');
      _selectedUsageFrequency =
          widget.initialFlashcard!.usageFrequency.isNotEmpty
              ? widget.initialFlashcard!.usageFrequency
              : 'Common';
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _pronunciationController.dispose();
    _audioUrlController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Convert comma-separated strings to lists
      final synonymsList = _synonymsController.text.isNotEmpty
          ? _synonymsController.text.split(',').map((s) => s.trim()).toList()
          : <String>[];

      final antonymsList = _antonymsController.text.isNotEmpty
          ? _antonymsController.text.split(',').map((s) => s.trim()).toList()
          : <String>[];

      final flashcard = Flashcard(
        id: widget.initialFlashcard?.id ?? '',
        word: _wordController.text,
        translation: _translationController.text,
        example: _exampleController.text,
        exampleTranslation: _exampleTranslationController.text,
        imageUrl: _imageUrlController.text,
        category: _categoryController.text,
        difficulty: _selectedDifficulty,
        isFavorite: widget.initialFlashcard?.isFavorite ?? false,
        pronunciation: _pronunciationController.text,
        audioUrl: _audioUrlController.text,
        synonyms: synonymsList,
        antonyms: antonymsList,
        usageFrequency: _selectedUsageFrequency,
      );

      widget.onSave(flashcard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.initialFlashcard != null ? 'Kartı Düzenle' : 'Yeni Kart Ekle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Kaydet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Word field
            TextFormField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Kelime *',
                hintText: 'Örn: Serendipity',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir kelime girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Translation field
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Çeviri *',
                hintText: 'Örn: Şans eseri',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen çeviri girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pronunciation field
            TextFormField(
              controller: _pronunciationController,
              decoration: const InputDecoration(
                labelText: 'Telaffuz',
                hintText: 'Örn: /ser·ən·dip·ə·tē/',
              ),
            ),
            const SizedBox(height: 16),

            // Audio URL field
            TextFormField(
              controller: _audioUrlController,
              decoration: const InputDecoration(
                labelText: 'Ses Dosyası URL',
                hintText: 'Örn: https://example.com/audio/word.mp3',
              ),
            ),
            const SizedBox(height: 16),

            // Example field
            TextFormField(
              controller: _exampleController,
              decoration: const InputDecoration(
                labelText: 'Örnek Cümle',
                hintText: 'Örn: Meeting my wife was pure serendipity.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Example translation field
            TextFormField(
              controller: _exampleTranslationController,
              decoration: const InputDecoration(
                labelText: 'Örnek Cümle Çevirisi',
                hintText: 'Örn: Eşimle tanışmam tam bir şans eseriydi.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Synonyms field
            TextFormField(
              controller: _synonymsController,
              decoration: const InputDecoration(
                labelText: 'Eş Anlamlılar',
                hintText: 'Virgülle ayırın, Örn: chance, coincidence, luck',
              ),
            ),
            const SizedBox(height: 16),

            // Antonyms field
            TextFormField(
              controller: _antonymsController,
              decoration: const InputDecoration(
                labelText: 'Zıt Anlamlılar',
                hintText:
                    'Virgülle ayırın, Örn: planning, calculation, intention',
              ),
            ),
            const SizedBox(height: 16),

            // Image URL field
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Görsel URL',
                hintText: 'Örn: https://example.com/images/word.jpg',
              ),
            ),
            const SizedBox(height: 16),

            // Category field
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                hintText: 'Örn: Abstract',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir kategori girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty dropdown
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Zorluk',
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Usage frequency dropdown
            DropdownButtonFormField<String>(
              value: _selectedUsageFrequency,
              decoration: const InputDecoration(
                labelText: 'Kullanım Sıklığı',
              ),
              items: _usageFrequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUsageFrequency = value!;
                });
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.initialFlashcard != null
                    ? 'Kartı Güncelle'
                    : 'Kart Oluştur',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
