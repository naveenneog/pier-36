import 'package:flutter/material.dart';

import '../tokens.dart';

/// Stories-style segmented progress indicator across a channel of cards.
class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    required this.count,
    required this.activeIndex,
    this.progress = 0,
    super.key,
  });

  final int count;
  final int activeIndex;

  /// 0..1 fill of the active segment.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: i < activeIndex
                    ? 1.0
                    : (i == activeIndex ? progress.clamp(0.0, 1.0) : 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
