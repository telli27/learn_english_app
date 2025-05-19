import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class CustomCardForm extends StatefulWidget {
  final Function(Flashcard) onSave;
  final Flashcard? initialFlashcard;

  const CustomCardForm({
    Key? key,
    required this.onSave,
    this.initialFlashcard,
  }) : super(key: key);

  @override
  State<CustomCardForm> createState() => _CustomCardFormState();
}

class _CustomCardFormState extends State<CustomCardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _exampleTranslationController =
      TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = 'Other';
  String _selectedDifficulty = 'Beginner';

  final List<String> _categories = [
    'Food',
    'Technology',
    'Education',
    'Travel',
    'Business',
    'Health',
    'Home',
    'Transportation',
    'Other'
  ];

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();

    // If editing an existing card, populate the form
    if (widget.initialFlashcard != null) {
      _wordController.text = widget.initialFlashcard!.word;
      _translationController.text = widget.initialFlashcard!.translation;
      _exampleController.text = widget.initialFlashcard!.example;
      _exampleTranslationController.text =
          widget.initialFlashcard!.exampleTranslation;
      _imageUrlController.text = widget.initialFlashcard!.imageUrl;

      _selectedCategory = widget.initialFlashcard!.category;
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }

      _selectedDifficulty = widget.initialFlashcard!.difficulty;
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a new flashcard with the form data
      final flashcard = Flashcard(
        id: widget.initialFlashcard?.id ??
            '', // Empty ID will be replaced with a generated one
        word: _wordController.text.trim(),
        translation: _translationController.text.trim(),
        example: _exampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        isFavorite: widget.initialFlashcard?.isFavorite ?? false,
      );

      // Call the onSave callback
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
            // Word input
            _buildTextField(
              controller: _wordController,
              label: 'Kelime (İngilizce)',
              hint: 'Örn: Apple',
              icon: Icons.text_fields,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen kelimeyi girin';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Translation input
            _buildTextField(
              controller: _translationController,
              label: 'Çevirisi (Türkçe)',
              hint: 'Örn: Elma',
              icon: Icons.translate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen çevirisini girin';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Example input
            _buildTextField(
              controller: _exampleController,
              label: 'Örnek Cümle (İngilizce)',
              hint: 'Örn: I eat an apple every day.',
              icon: Icons.format_quote,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Example Translation input
            _buildTextField(
              controller: _exampleTranslationController,
              label: 'Örnek Cümle Çevirisi (Türkçe)',
              hint: 'Örn: Her gün bir elma yerim.',
              icon: Icons.format_quote,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Image URL input
            _buildTextField(
              controller: _imageUrlController,
              label: 'Görsel URL (İsteğe bağlı)',
              hint: 'Örn: https://example.com/image.png',
              icon: Icons.image,
            ),

            const SizedBox(height: 24),

            // Category dropdown
            _buildDropdown(
              label: 'Kategori',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              icon: Icons.category,
            ),

            const SizedBox(height: 16),

            // Difficulty dropdown
            _buildDropdown(
              label: 'Zorluk Seviyesi',
              value: _selectedDifficulty,
              items: _difficulties,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
              icon: Icons.trending_up,
            ),

            const SizedBox(height: 32),

            // Preview section
            if (_wordController.text.isNotEmpty ||
                _translationController.text.isNotEmpty)
              _buildPreview(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPreview(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ön İzleme',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word and Translation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _wordController.text.isEmpty
                              ? 'Kelime'
                              : _wordController.text,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _translationController.text.isEmpty
                              ? 'Çeviri'
                              : _translationController.text,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_imageUrlController.text.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        _imageUrlController.text,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Example and Translation
              if (_exampleController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exampleController.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (_exampleTranslationController.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _exampleTranslationController.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Category and Difficulty badges
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedDifficulty == 'Beginner'
                          ? Colors.green.shade700
                          : _selectedDifficulty == 'Intermediate'
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedDifficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
