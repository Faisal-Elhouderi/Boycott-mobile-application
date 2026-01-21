import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/verdict_helper.dart';
import '../../../core/widgets/search_input.dart';
import '../../common/widgets/verdict_badge.dart';
import '../data/alternatives_repository.dart';
import '../models/alternative.dart';

class AlternativesScreen extends ConsumerStatefulWidget {
  const AlternativesScreen({super.key});

  @override
  ConsumerState<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends ConsumerState<AlternativesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(alternativesSearchProvider.notifier).state = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alternativesAsync = ref.watch(alternativesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alternatives),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(alternativesProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchInput(
              controller: _searchController,
              hintText: l10n.searchAlternativesHint,
              onChanged: _onSearchChanged,
              onSubmitted: () => ref.invalidate(alternativesProvider),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: alternativesAsync.when(
                data: (alternatives) => _AlternativesList(alternatives: alternatives),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  title: l10n.error,
                  message: l10n.alternativesLoadFailed,
                  actionLabel: l10n.retry,
                  onRetry: () => ref.invalidate(alternativesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativesList extends StatelessWidget {
  final List<AlternativeSummary> alternatives;

  const _AlternativesList({required this.alternatives});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (alternatives.isEmpty) {
      return _EmptyState(
        title: l10n.noAlternativesTitle,
        subtitle: l10n.noAlternativesSubtitle,
      );
    }

    return ListView.separated(
      itemCount: alternatives.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alternative = alternatives[index];
        final verdict = resolveVerdict(alternative.verdict, alternative.verdictLabel);
        final verdictLabel = alternative.verdictLabel.isNotEmpty
            ? alternative.verdictLabel
            : l10n.preferred;

        return InkWell(
          onTap: () => context.push('/alternatives/${alternative.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                _LeadingIcon(text: alternative.displayName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alternative.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (alternative.brand.isNotEmpty)
                        Text(
                          alternative.brand,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (alternative.company.isNotEmpty)
                        Text(
                          alternative.company,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    VerdictBadge(
                      verdict: verdict,
                      size: VerdictBadgeSize.small,
                    ),
                    if (alternative.verdictLabel.isNotEmpty)
                      Text(
                        verdictLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: VerdictStyles.getColor(verdict),
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final String text;

  const _LeadingIcon({required this.text});

  @override
  Widget build(BuildContext context) {
    final first = text.isNotEmpty ? text.substring(0, 1) : '؟';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          first,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
