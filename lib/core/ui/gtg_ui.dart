import 'package:flutter/material.dart';

/// Shared UI tokens and responsive rules used by GTG screens.
abstract final class GtgUi {
  static const double collapsedNavigationWidth = 340;
  static const double compactWidth = 360;
  static const double compactActionWidth = 420;
  static const double compactDetailWidth = 300;
  static const double elevatedTextScale = 1.25;
  static const double largeTextScale = 1.3;
  static const double accessibilityTextScale = 1.4;
  static const double screenTopPadding = 14;
  static const double screenBottomPadding = 28;
  static const double screenHorizontalPadding = 16;
  static const double primarySectionSpacing = 12;
  static const double secondarySectionSpacing = 10;
  static const double contentSpacing = 14;
  static const double controlSpacing = 12;
  static const double sectionPadding = 16;
  static const double cardRadius = 20;
  static const double controlRadius = 14;
  static const double pillRadius = 999;
  static const Duration emphasisAnimationDuration = Duration(milliseconds: 220);

  /// Returns true when the current width should collapse side-by-side content.
  static bool isCompactWidth(double width, {double threshold = compactWidth}) {
    return width < threshold;
  }

  /// Returns true when text scaling requires accessibility-first stacking.
  static bool isLargeTextScale(
    double textScale, {
    double threshold = largeTextScale,
  }) {
    return textScale >= threshold;
  }

  /// Returns true when either width or text scale requires a compact layout.
  static bool useCompactLayout({
    required double width,
    required double textScale,
    double widthThreshold = compactWidth,
    double textScaleThreshold = largeTextScale,
  }) {
    return isCompactWidth(width, threshold: widthThreshold) ||
        isLargeTextScale(textScale, threshold: textScaleThreshold);
  }
}

/// Shared page intro that keeps title/subtitle/trailing content aligned across screens.
class GtgPageIntro extends StatelessWidget {
  const GtgPageIntro({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompactHeader = GtgUi.useCompactLayout(
          width: constraints.maxWidth,
          textScale: textScale,
          textScaleThreshold: GtgUi.elevatedTextScale,
        );
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle case final subtitle?) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );

        if (trailing == null) {
          return titleBlock;
        }

        if (useCompactHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleBlock,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: titleBlock),
            const SizedBox(width: GtgUi.controlSpacing),
            trailing!,
          ],
        );
      },
    );
  }
}

/// Shared elevated section card chrome used across feature screens.
class GtgSectionCard extends StatelessWidget {
  const GtgSectionCard({
    super.key,
    this.icon,
    this.accent,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      GtgUi.sectionPadding,
      GtgUi.sectionPadding,
      GtgUi.sectionPadding,
      GtgUi.sectionPadding,
    ),
  });

  final IconData? icon;
  final Color? accent;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedAccent = accent ?? colorScheme.primary;
    final hasHeader =
        title != null || subtitle != null || icon != null || trailing != null;

    return Card(
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useCompactHeader =
                trailing != null &&
                GtgUi.useCompactLayout(
                  width: constraints.maxWidth,
                  textScale: textScale,
                  textScaleThreshold: GtgUi.elevatedTextScale,
                );
            final headerContent = _SectionCardHeaderContent(
              icon: icon,
              accent: resolvedAccent,
              title: title,
              subtitle: subtitle,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hasHeader) ...<Widget>[
                  _SectionCardHeaderLayout(
                    headerContent: headerContent,
                    trailing: trailing,
                    useCompactHeader: useCompactHeader,
                  ),
                  const SizedBox(height: GtgUi.controlSpacing),
                ],
                child,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCardHeaderContent extends StatelessWidget {
  const _SectionCardHeaderContent({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final IconData? icon;
  final Color accent;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (icon case final icon?) ...<Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                accent.withValues(alpha: 0.12),
                colorScheme.surface,
              ),
              borderRadius: BorderRadius.circular(GtgUi.controlRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: accent, size: 20),
            ),
          ),
          const SizedBox(width: GtgUi.controlSpacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title case final title?)
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              if (subtitle case final subtitle?) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCardHeaderLayout extends StatelessWidget {
  const _SectionCardHeaderLayout({
    required this.headerContent,
    required this.trailing,
    required this.useCompactHeader,
  });

  final Widget headerContent;
  final Widget? trailing;
  final bool useCompactHeader;

  @override
  Widget build(BuildContext context) {
    if (useCompactHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          headerContent,
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: headerContent),
        if (trailing case final trailing?) ...<Widget>[
          const SizedBox(width: GtgUi.controlSpacing),
          trailing,
        ],
      ],
    );
  }
}

/// Shared responsive pair layout for two related controls or a detail+trailing action.
class GtgResponsivePair extends StatelessWidget {
  const GtgResponsivePair({
    super.key,
    required this.primary,
    required this.secondary,
    this.spacing = GtgUi.controlSpacing,
    this.expandPrimary = true,
    this.expandSecondary = true,
    this.widthThreshold = GtgUi.compactWidth,
    this.textScaleThreshold = GtgUi.largeTextScale,
    this.compactCrossAxisAlignment = CrossAxisAlignment.start,
    this.compactSecondaryAlignment,
  });

  final Widget primary;
  final Widget secondary;
  final double spacing;
  final bool expandPrimary;
  final bool expandSecondary;
  final double widthThreshold;
  final double textScaleThreshold;
  final CrossAxisAlignment compactCrossAxisAlignment;
  final AlignmentGeometry? compactSecondaryAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompact = GtgUi.useCompactLayout(
          width: constraints.maxWidth,
          textScale: textScale,
          widthThreshold: widthThreshold,
          textScaleThreshold: textScaleThreshold,
        );

        if (useCompact) {
          return Column(
            crossAxisAlignment: compactCrossAxisAlignment,
            children: <Widget>[
              primary,
              SizedBox(height: spacing),
              if (compactSecondaryAlignment case final alignment?)
                Align(alignment: alignment, child: secondary)
              else
                secondary,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (expandPrimary) Expanded(child: primary) else primary,
            SizedBox(width: spacing),
            if (expandSecondary) Expanded(child: secondary) else secondary,
          ],
        );
      },
    );
  }
}

/// Shared responsive layout for small groups of equal-priority tiles.
class GtgResponsiveGroup extends StatelessWidget {
  const GtgResponsiveGroup({
    super.key,
    required this.children,
    this.spacing = GtgUi.secondarySectionSpacing,
    this.widthThreshold = GtgUi.compactWidth,
    this.textScaleThreshold = GtgUi.largeTextScale,
    this.expandChildren = true,
    this.compactCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double widthThreshold;
  final double textScaleThreshold;
  final bool expandChildren;
  final CrossAxisAlignment compactCrossAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompact = GtgUi.useCompactLayout(
          width: constraints.maxWidth,
          textScale: textScale,
          widthThreshold: widthThreshold,
          textScaleThreshold: textScaleThreshold,
        );

        if (useCompact) {
          return Column(
            crossAxisAlignment: compactCrossAxisAlignment,
            children: <Widget>[
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: rowCrossAxisAlignment,
          children: <Widget>[
            for (var index = 0; index < children.length; index++) ...[
              if (expandChildren)
                Expanded(child: children[index])
              else
                children[index],
              if (index != children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}

/// Shared selected/unselected card pattern used by settings and onboarding choices.
class GtgSelectableCard extends StatelessWidget {
  const GtgSelectableCard({
    super.key,
    this.icon,
    this.leading,
    required this.accent,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.inMutuallyExclusiveGroup = true,
  });

  final IconData? icon;
  final Widget? leading;
  final Color accent;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;
  final bool inMutuallyExclusiveGroup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnTap = enabled ? onTap : null;
    final backgroundColor = selected
        ? Color.alphaBlend(accent.withValues(alpha: 0.12), colorScheme.surface)
        : colorScheme.surface;
    final borderColor = selected ? accent : colorScheme.outlineVariant;
    final leadingBackground = selected
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            colorScheme.surfaceContainerHigh,
          )
        : colorScheme.surfaceContainerHigh;
    final leadingColor = selected ? accent : colorScheme.onSurfaceVariant;
    final trailingIcon = selected
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;
    final resolvedLeading =
        leading ??
        Icon(icon ?? Icons.circle_rounded, color: leadingColor, size: 18);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
          onTap: effectiveOnTap,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
              border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: leadingBackground,
                      borderRadius: BorderRadius.circular(
                        GtgUi.controlRadius - 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: resolvedLeading,
                    ),
                  ),
                  const SizedBox(width: GtgUi.controlSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (subtitle case final subtitle?) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: GtgUi.controlSpacing),
                  Icon(trailingIcon, color: leadingColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared compact informational banner for explanatory helper copy.
class GtgInfoBanner extends StatelessWidget {
  const GtgInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.accent,
    this.backgroundColor,
    this.borderColor,
    this.iconBackground = true,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 10),
    this.textStyle,
  });

  final String message;
  final IconData icon;
  final Color? accent;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool iconBackground;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedAccent = accent ?? colorScheme.primary;
    final resolvedBackground =
        backgroundColor ??
        Color.alphaBlend(
          resolvedAccent.withValues(alpha: 0.08),
          colorScheme.surface,
        );
    final resolvedBorder =
        borderColor ?? resolvedAccent.withValues(alpha: 0.16);
    final iconWidget = Icon(icon, color: resolvedAccent, size: 18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(GtgUi.controlRadius),
        border: Border.all(color: resolvedBorder),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            if (iconBackground)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: resolvedAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GtgUi.controlRadius - 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: iconWidget,
                ),
              )
            else
              iconWidget,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style:
                    textStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared compact informational state for empty/loading helper blocks.
class GtgEmptyState extends StatelessWidget {
  const GtgEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.controlRadius + 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
