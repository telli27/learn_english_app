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
}
