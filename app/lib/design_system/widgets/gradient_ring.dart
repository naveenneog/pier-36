import 'package:flutter/material.dart';

import '../../features/feed/domain/entities/feed_card.dart';
import '../gradients.dart';

/// Circular gradient "story ring" wrapping a source/figure avatar.
class GradientRing extends StatelessWidget {
  const GradientRing({
    required this.source,
    this.size = 44,
    this.child,
    super.key,
  });

  final SourceType source;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.forSource(source),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF16161F),
        ),
        child: child,
      ),
    );
  }
}
