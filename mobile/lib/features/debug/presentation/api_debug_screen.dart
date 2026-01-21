import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

final debugInfoProvider = FutureProvider<DebugInfo>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final healthResponse = await apiClient.getHealth();
  final productsResponse = await apiClient.getProducts();

  final healthSummary = _healthSummary(healthResponse.data);
  final productCount = _itemCount(productsResponse.data);

  return DebugInfo(
    baseUrl: ApiClient.rootUrl,
    healthSummary: healthSummary,
    itemCount: productCount,
  );
});

class ApiDebugScreen extends ConsumerWidget {
  const ApiDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final debugAsync = ref.watch(debugInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.apiDebug),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(debugInfoProvider),
          ),
        ],
      ),
      body: debugAsync.when(
        data: (info) {
          final healthValue = info.healthSummary.isEmpty ? l10n.unknown : info.healthSummary;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: l10n.health,
                value: healthValue,
                icon: Icons.favorite_outline,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: l10n.productCount,
                value: info.itemCount.toString(),
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: l10n.baseUrl,
                value: info.baseUrl,
                icon: Icons.link,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: l10n.debugUnavailable,
          message: '${l10n.error}\n${error.toString()}',
          actionLabel: l10n.retry,
          onRetry: () => ref.invalidate(debugInfoProvider),
        ),
      ),
    );
  }
}

class DebugInfo {
  final String baseUrl;
  final String healthSummary;
  final int itemCount;

  DebugInfo({
    required this.baseUrl,
    required this.healthSummary,
    required this.itemCount,
  });
}

String _healthSummary(dynamic payload) {
  if (payload is Map) {
    final status = payload['status'] ?? payload['message'] ?? payload['ok'];
    if (status != null) {
      return status.toString();
    }
    return payload.toString();
  }
  if (payload == null) {
    return '';
  }
  return payload.toString();
}

int _itemCount(dynamic payload) {
  final listPayload = unwrapSuccessList(payload);
  if (listPayload.isNotEmpty) {
    return listPayload.length;
  }
  if (payload is List) {
    return payload.length;
  }
  if (payload is Map) {
    final candidates = [
      payload['count'],
      payload['total'],
      payload['totalCount'],
      payload['items'],
    ];
    for (final candidate in candidates) {
      if (candidate is int) {
        return candidate;
      }
      if (candidate is List) {
        return candidate.length;
      }
    }
  }
  return 0;
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
