import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../common/widgets/verdict_badge.dart';

class ScanResultScreen extends ConsumerWidget {
  final String barcode;

  const ScanResultScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(l10n.scan),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('📦', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كوكاكولا 330 مل',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Coca-Cola',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The Coca-Cola Company',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      Text(
                        barcode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.avoid, Color(0xFFB91C1C)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🚫', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.avoid,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(label: '${l10n.confidence}: عالية'),
                _StatusChip(label: '${l10n.status}: موثّق'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.swap_horiz,
                    label: l10n.alternatives,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.info_outline,
                    label: l10n.why,
                    color: AppColors.caution,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.account_tree_outlined,
                    label: l10n.ownershipChain,
                    color: AppColors.textSecondary,
                    onTap: () => context.push('/company/coca-cola'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.alternatives,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _AlternativeCard(
              name: 'آر سي كولا',
              brand: 'RC Cola',
              isExact: true,
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            _AlternativeCard(
              name: 'مشروب محلي',
              brand: 'علامة محلية',
              isExact: false,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.preferredLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.preferred.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.preferred, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.whereToBuy,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          Text(
                            'اعرف المتاجر المتوفرة بالقرب منك',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: Text(l10n.shareInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final String name;
  final String brand;
  final bool isExact;
  final AppLocalizations l10n;

  const _AlternativeCard({
    required this.name,
    required this.brand,
    required this.isExact,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.preferredLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('✅', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isExact) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.exactMatch,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  brand,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const VerdictBadge(verdict: 'PREFERRED', size: VerdictBadgeSize.small),
        ],
      ),
    );
  }
}
