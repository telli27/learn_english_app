import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final List<String> examples;
  final String color;
  final String iconPath;
  final List<GrammarSubtopic> subtopics;
  final String grammar_structure;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.examples,
    required this.color,
    required this.iconPath,
    this.subtopics = const [],
    this.grammar_structure = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrammarTopic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ description.hashCode;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    // Debug information to identify problematic fields
    debugPrint('Parsing grammar topic: ${json['title']}');

    try {
      return GrammarTopic(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        examples: json['examples'] != null
            ? List<String>.from(
                json['examples'].map((x) => x?.toString() ?? ''))
            : [],
        color: json['color']?.toString() ?? '#FFC107',
        iconPath: json['iconPath']?.toString() ?? 'assets/icons/grammar.svg',
        grammar_structure: json['grammar_structure']?.toString() ?? '',
        subtopics: json['subtopics'] != null
            ? List<GrammarSubtopic>.from(
                json['subtopics'].map((x) => GrammarSubtopic.fromJson(x)))
            : [],
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing GrammarTopic: $e');
      debugPrint('JSON data: $json');
      debugPrint('Stack trace: $stackTrace');
      // Return a placeholder topic instead of throwing an exception
      return GrammarTopic(
        id: json['id']?.toString() ?? 'error',
        title: 'Error loading topic',
        description: 'There was an error loading this topic',
        examples: [],
        color: '#FF0000',
        iconPath: 'assets/icons/grammar.svg',
      );
    }
  }
}

class GrammarSubtopic {
  final String id;
  final String title;
  final String description;
  final List<String> examples;
  final String grammar_structure;
  final List<String> exercises;

  const GrammarSubtopic({
    required this.id,
    required this.title,
    required this.description,
    required this.examples,
    this.grammar_structure = '',
    this.exercises = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrammarSubtopic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ description.hashCode;

  factory GrammarSubtopic.fromJson(Map<String, dynamic> json) {
    try {
      return GrammarSubtopic(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        examples: json['examples'] != null
            ? List<String>.from(
                json['examples'].map((x) => x?.toString() ?? ''))
            : [],
        grammar_structure: json['grammar_structure']?.toString() ?? '',
        exercises: json['exercises'] != null
            ? List<String>.from(
                json['exercises'].map((x) => x?.toString() ?? ''))
            : [],
      );
    } catch (e) {
      debugPrint('Error parsing GrammarSubtopic: $e');
      debugPrint('JSON data: $json');
      // Return a placeholder subtopic instead of throwing an exception
      return GrammarSubtopic(
        id: 'error',
        title: 'Error loading subtopic',
        description: 'There was an error loading this subtopic',
        examples: [],
      );
    }
  }
}
