import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final List<String> examples;
  final String color;
  final String iconPath;
  final String grammar_structure;
  final List<GrammarSubtopic> subtopics;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    this.examples = const [],
    required this.color,
    required this.iconPath,
    this.grammar_structure = '',
    this.subtopics = const [],
  });
}

class GrammarSubtopic {
  final String id;
  final String title;
  final String description;
  final List<String> examples;
  final String grammar_structure;
  final List<String>? exercises;

  GrammarSubtopic({
    required this.id,
    required this.title,
    required this.description,
    this.examples = const [],
    this.grammar_structure = '',
    this.exercises,
  });
}
