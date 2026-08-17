import 'package:flutter/material.dart';

import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:cv_bank/core/utils/date_format.dart';
import 'package:cv_bank/features/dashboard/domain/entities/dashboard_stats.dart';

/// Plain card. Border rather than elevation, since shadows go muddy
/// on the warm background.
class DashCard extends StatelessWidget {
  const DashCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: child,
    );
  }
}

// =====================================================================
// Hero: total people with the employed split
// =====================================================================

class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.totals, this.onTapSegment});

  final DashboardTotals totals;

  /// true = employed, false = waiting. Opens the filtered people list.
  final ValueChanged<bool>? onTapSegment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashCard(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total people', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            _format(totals.totalPeople),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 34,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.md + 2),

          // The bar will look nearly empty for most accounts. That is
          // the point: it shows how much of the pool is untouched.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: totals.employedRatio,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: const AlwaysStoppedAnimation(AppColors.employed),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              _Legend(
                colour: AppColors.employed,
                count: totals.employed,
                label: 'employed',
                onTap: onTapSegment == null ? null : () => onTapSegment!(true),
              ),
              const SizedBox(width: AppSpacing.lg + 2),
              _Legend(
                colour: AppColors.borderStrong,
                count: totals.unemployed,
                label: 'waiting',
                onTap: onTapSegment == null ? null : () => onTapSegment!(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.colour,
    required this.count,
    required this.label,
    this.onTap,
  });

  final Color colour;
  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AppSpacing.sm - 1),
            Text(
              _format(count),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Two monthly tiles
// =====================================================================

class MonthlyTiles extends StatelessWidget {
  const MonthlyTiles({super.key, required this.added, required this.placed});

  final int added;
  final int placed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(label: 'Added this month', value: added),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: _Tile(
            label: 'Placed this month',
            value: placed,
            valueColour: AppColors.employed,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, this.valueColour});

  final String label;
  final int value;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _format(value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              color: valueColour,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Recent placements
// =====================================================================

class RecentPlacementsCard extends StatelessWidget {
  const RecentPlacementsCard({
    super.key,
    required this.placements,
    this.onSeeAll,
    this.onTapPerson,
  });

  final List<RecentPlacement> placements;
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onTapPerson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent placements', style: theme.textTheme.titleMedium),
              if (onSeeAll != null && placements.isNotEmpty)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),

          if (placements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Nobody placed yet. Mark someone employed and they '
                'will show up here.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...placements.map(
              (p) => _PlacementRow(
                placement: p,
                isLast: p == placements.last,
                onTap: onTapPerson == null
                    ? null
                    : () => onTapPerson!(p.personId),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlacementRow extends StatelessWidget {
  const _PlacementRow({
    required this.placement,
    required this.isLast,
    this.onTap,
  });

  final RecentPlacement placement;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = placement.subtitle;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
        margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Avatar(name: placement.personName),
            const SizedBox(width: AppSpacing.md - 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placement.personName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppDate.relative(placement.startedOn),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Initials circle. Used here and on the people list.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// =====================================================================
// Category breakdown
// =====================================================================

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({
    super.key,
    required this.categories,
    this.onTapCategory,
  });

  final List<CategoryStat> categories;
  final ValueChanged<String>? onTapCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('By category', style: theme.textTheme.titleMedium),
              Text('placed / total', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (categories.isEmpty)
            Text(
              'Add people to a category to see this.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...categories.map(
              (c) => Padding(
                padding: EdgeInsets.only(
                  bottom: c == categories.last ? 0 : AppSpacing.md + 2,
                ),
                child: _CategoryBar(
                  stat: c,
                  onTap: onTapCategory == null
                      ? null
                      : () => onTapCategory!(c.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.stat, this.onTap});

  final CategoryStat stat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  stat.name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  children: [
                    TextSpan(
                      text: _format(stat.employed),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' / ${_format(stat.pool)}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: stat.ratio,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: const AlwaysStoppedAnimation(AppColors.employed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================

/// 1248 -> 1,248
String _format(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
