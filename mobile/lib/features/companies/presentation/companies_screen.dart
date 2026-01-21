import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/verdict_helper.dart';
import '../../../core/widgets/search_input.dart';
import '../../common/widgets/verdict_badge.dart';
import '../data/companies_repository.dart';
import '../models/company.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(companiesSearchProvider.notifier).state = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.companies),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(companiesProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchInput(
              controller: _searchController,
              hintText: l10n.searchCompaniesHint,
              onChanged: _onSearchChanged,
              onSubmitted: () => ref.invalidate(companiesProvider),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: companiesAsync.when(
                data: (companies) => _CompaniesList(companies: companies),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  title: l10n.error,
                  message: l10n.companiesLoadFailed,
                  actionLabel: l10n.retry,
                  onRetry: () => ref.invalidate(companiesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompaniesList extends StatelessWidget {
  final List<CompanySummary> companies;

  const _CompaniesList({required this.companies});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (companies.isEmpty) {
      return _EmptyState(
        title: l10n.noCompaniesTitle,
        subtitle: l10n.noCompaniesSubtitle,
      );
    }

    return ListView.separated(
      itemCount: companies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final company = companies[index];
        final verdict = resolveVerdict(company.verdict, company.verdictLabel);
        final verdictLabel = company.verdictLabel.isNotEmpty
            ? company.verdictLabel
            : l10n.unknown;

        return InkWell(
          onTap: () => context.push('/company/${company.id}'),
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
                _LeadingIcon(text: company.displayName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (company.country.isNotEmpty)
                        Text(
                          company.country,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (company.description.isNotEmpty)
                        Text(
                          company.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    if (company.verdictLabel.isNotEmpty)
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
            const Icon(Icons.apartment, size: 48, color: AppColors.border),
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
