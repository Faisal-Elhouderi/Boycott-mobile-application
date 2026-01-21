import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

enum VerdictBadgeSize { small, medium, large }

class VerdictBadge extends StatelessWidget {
  final String verdict;
  final VerdictBadgeSize size;
  final bool showIcon;

  const VerdictBadge({
    super.key,
    required this.verdict,
    this.size = VerdictBadgeSize.medium,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final config = _getConfig(verdict, l10n);
    final sizeConfig = _getSizeConfig(size);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConfig.paddingHorizontal,
        vertical: sizeConfig.paddingVertical,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Text(
              config.icon,
              style: TextStyle(fontSize: sizeConfig.iconSize),
            ),
            SizedBox(width: sizeConfig.spacing),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: sizeConfig.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _VerdictConfig _getConfig(String verdict, AppLocalizations l10n) {
    switch (verdict.toUpperCase()) {
      case 'AVOID':
        return _VerdictConfig(
          label: l10n.avoid,
          icon: '🚫',
          backgroundColor: AppColors.avoidLight,
          textColor: AppColors.avoid,
          borderColor: AppColors.avoid.withOpacity(0.3),
        );
      case 'CAUTION':
        return _VerdictConfig(
          label: l10n.caution,
          icon: '⚠️',
          backgroundColor: AppColors.cautionLight,
          textColor: AppColors.caution,
          borderColor: AppColors.caution.withOpacity(0.3),
        );
      case 'PREFERRED':
        return _VerdictConfig(
          label: l10n.preferred,
          icon: '✅',
          backgroundColor: AppColors.preferredLight,
          textColor: AppColors.preferred,
          borderColor: AppColors.preferred.withOpacity(0.3),
        );
      default:
        return _VerdictConfig(
          label: l10n.unknown,
          icon: '❓',
          backgroundColor: AppColors.unknownLight,
          textColor: AppColors.unknown,
          borderColor: AppColors.unknown.withOpacity(0.3),
        );
    }
  }

  _SizeConfig _getSizeConfig(VerdictBadgeSize size) {
    switch (size) {
      case VerdictBadgeSize.small:
        return const _SizeConfig(
          paddingHorizontal: 8,
          paddingVertical: 4,
          borderRadius: 12,
          fontSize: 12,
          iconSize: 12,
          spacing: 4,
        );
      case VerdictBadgeSize.medium:
        return const _SizeConfig(
          paddingHorizontal: 12,
          paddingVertical: 6,
          borderRadius: 16,
          fontSize: 14,
          iconSize: 14,
          spacing: 6,
        );
      case VerdictBadgeSize.large:
        return const _SizeConfig(
          paddingHorizontal: 16,
          paddingVertical: 8,
          borderRadius: 20,
          fontSize: 16,
          iconSize: 16,
          spacing: 8,
        );
    }
  }
}

class _VerdictConfig {
  final String label;
  final String icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _VerdictConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

class _SizeConfig {
  final double paddingHorizontal;
  final double paddingVertical;
  final double borderRadius;
  final double fontSize;
  final double iconSize;
  final double spacing;

  const _SizeConfig({
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.borderRadius,
    required this.fontSize,
    required this.iconSize,
    required this.spacing,
  });
}

