import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/verdict_helper.dart';
import '../../common/widgets/verdict_badge.dart';
import '../../products/models/product.dart';
import '../data/companies_repository.dart';
import '../models/company.dart';

class CompanyScreen extends ConsumerWidget {
  final String companyId;

  const CompanyScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companyAsync = ref.watch(companyDetailProvider(companyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.companyDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: companyAsync.when(
        data: (detail) => _CompanyDetailBody(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: l10n.error,
          message: l10n.companyLoadFailed,
          actionLabel: l10n.retry,
          onRetry: () => ref.invalidate(companyDetailProvider(companyId)),
        ),
      ),
    );
  }
}

class _CompanyDetailBody extends StatelessWidget {
  final CompanyDetail detail;

  const _CompanyDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final company = detail.company;
    final verdict = resolveVerdict(company.verdict, company.verdictLabel);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _LeadingIcon(text: company.displayName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (company.country.isNotEmpty)
                          Text(
                            company.country,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  VerdictBadge(verdict: verdict, size: VerdictBadgeSize.small),
                ],
              ),
              if (company.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  company.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.products,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (detail.products.isEmpty)
          _EmptyState(
            title: l10n.noCompanyProductsTitle,
            subtitle: l10n.noCompanyProductsSubtitle,
          )
        else
          ...detail.products.map(
            (product) => _CompanyProductCard(product: product),
          ),
      ],
    );
  }
}

class _CompanyProductCard extends StatelessWidget {
  final ProductSummary product;

  const _CompanyProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdict = resolveVerdict(product.verdict, product.verdictLabel);

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            _LeadingIcon(text: product.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (product.brand.isNotEmpty)
                    Text(
                      product.brand,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (product.category.isNotEmpty)
                    Text(
                      '${l10n.category}: ${product.category}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                VerdictBadge(verdict: verdict, size: VerdictBadgeSize.small),
                if (product.verdictLabel.isNotEmpty)
                  Text(
                    product.verdictLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: VerdictStyles.getColor(verdict),
                        ),
                  ),
                if (product.verdictLabel.isEmpty)
                  Text(
                    l10n.unknown,
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
  }
}

class _LeadingIcon extends StatelessWidget {
  final String text;

  const _LeadingIcon({required this.text});

  @override
  Widget build(BuildContext context) {
    final first = text.isNotEmpty ? text.substring(0, 1) : '؟';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          first,
          style: const TextStyle(
            fontSize: 18,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.border, size: 36),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
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
