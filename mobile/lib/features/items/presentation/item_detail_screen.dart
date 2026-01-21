import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/items_repository.dart';
import '../models/item.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.itemDetails),
      ),
      body: itemAsync.when(
        data: (item) => _ItemDetailView(item: item),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: l10n.error,
          message: '${l10n.itemLoadFailed}\n${error.toString()}',
          actionLabel: l10n.retry,
          onRetry: () => ref.invalidate(itemDetailProvider(itemId)),
        ),
      ),
    );
  }
}

class _ItemDetailView extends StatelessWidget {
  final Item item;

  const _ItemDetailView({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extraFields = item.extraFields;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.category?.isNotEmpty == true ? item.category! : l10n.uncategorized,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (item.status != null && item.status!.isNotEmpty)
                _StatusPill(label: item.status!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DetailCard(
          title: l10n.summary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: l10n.itemId,
                value: item.id ?? l10n.itemStatusUnknown,
              ),
              _DetailRow(
                label: l10n.status,
                value: item.status?.isNotEmpty == true ? item.status! : l10n.itemStatusUnknown,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (item.description != null && item.description!.trim().isNotEmpty)
          _DetailCard(
            title: l10n.description,
            child: Text(
              item.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        if (extraFields.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailCard(
            title: l10n.moreFields,
            child: Column(
              children: extraFields.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DetailRow(
                    label: entry.key,
                    value: entry.value?.toString() ?? '-',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'avoid':
        return AppColors.avoid;
      case 'preferred':
        return AppColors.preferred;
      case 'caution':
        return AppColors.caution;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
