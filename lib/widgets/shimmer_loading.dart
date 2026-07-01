import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading effect widget
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }
}

/// Basic shimmer box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// ShimmerCircle for avatars/icons
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Shimmer text line
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    super.key,
    this.width = 100,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Verse card skeleton
class VerseCardSkeleton extends StatelessWidget {
  const VerseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerText(width: 100, height: 12),
            const SizedBox(height: 12),
            const ShimmerText(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            const ShimmerText(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            const ShimmerText(width: 200, height: 16),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerText(width: 80, height: 12),
                Row(
                  children: [
                    ShimmerCircle(size: 32),
                    const SizedBox(width: 8),
                    ShimmerCircle(size: 32),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Achievement card skeleton
class AchievementCardSkeleton extends StatelessWidget {
  const AchievementCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const ShimmerCircle(size: 50),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerText(width: 120, height: 14),
                  SizedBox(height: 6),
                  ShimmerText(width: 180, height: 12),
                  SizedBox(height: 8),
                  ShimmerText(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reading plan card skeleton
class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 150, height: 16),
                      SizedBox(height: 6),
                      ShimmerText(width: 200, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerText(width: 100, height: 12),
            const SizedBox(height: 8),
            ShimmerBox(
              width: double.infinity,
              height: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// List skeleton with multiple items
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListSkeleton({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
