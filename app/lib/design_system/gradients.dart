import 'package:flutter/widgets.dart';

import '../features/feed/domain/entities/feed_card.dart';

/// Signature gradients for the "Fresh Stories" design language.
///
/// Each source/topic maps to a recognizable gradient identity (like a Story ring).
abstract class AppGradients {
  static const _begin = Alignment.topLeft;
  static const _end = Alignment.bottomRight;

  /// Brand / your Notes (Second Brain).
  static const aurora = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFF6E56F7), Color(0xFFB14DFF)],
  );

  /// AI / ML / LLM topics.
  static const nebula = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFB14DFF), Color(0xFF4D7CFF)],
  );

  /// Research / arXiv papers.
  static const frost = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFF5CC8FF), Color(0xFF6E72F7)],
  );

  /// Code / GitHub.
  static const mint = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFF18E0B5), Color(0xFF1FB6FF)],
  );

  /// Social (Reddit / X) / CTAs.
  static const pulse = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFFF6A3D), Color(0xFFFF3D77)],
  );

  /// Blogs / essays / highlights.
  static const solar = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFFFC14D), Color(0xFFFF7A45)],
  );

  /// Topic ↔ gradient mapping. Exhaustive over [SourceType].
  static LinearGradient forSource(SourceType source) {
    switch (source) {
      case SourceType.notes:
        return aurora;
      case SourceType.github:
        return mint;
      case SourceType.arxiv:
        return frost;
      case SourceType.blog:
        return solar;
      case SourceType.reddit:
      case SourceType.x:
        return pulse;
      case SourceType.newsletter:
        return nebula;
    }
  }
}
