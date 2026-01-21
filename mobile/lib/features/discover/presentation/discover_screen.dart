import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.discover,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتشف البدائل والمنتجات المحلية بسهولة.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.browseByCategory,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              _CategoryCard(icon: '🥤', name: 'المشروبات'),
              _CategoryCard(icon: '🍪', name: 'الوجبات الخفيفة'),
              _CategoryCard(icon: '🧼', name: 'التنظيف'),
              _CategoryCard(icon: '🧴', name: 'العناية'),
              _CategoryCard(icon: '🥛', name: 'الألبان'),
              _CategoryCard(icon: '🥫', name: 'المعلبات'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.didYouKnow,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cautionLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.caution.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تملك شركة PepsiCo علامات مثل Lay\'s وDoritos وQuaker بالإضافة إلى منتجات أخرى.',
                  style: TextStyle(color: Color(0xFF92400E)),
                ),
                SizedBox(height: 8),
                Text(
                  'تعرّف على البدائل المحلية',
                  style: TextStyle(
                    color: AppColors.caution,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.popularSwaps,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          const _SwapCard(from: 'كوكاكولا', to: 'مشروب محلي'),
          const SizedBox(height: 8),
          const _SwapCard(from: 'رقائق مستوردة', to: 'رقائق محلية'),
          const SizedBox(height: 8),
          const _SwapCard(from: 'شوكولاتة مستوردة', to: 'شوكولاتة محلية'),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String name;

  const _CategoryCard({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              name,
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

class _SwapCard extends StatelessWidget {
  final String from;
  final String to;

  const _SwapCard({required this.from, required this.to});

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
          Expanded(
            child: Column(
              children: [
                const Text('من', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                Text(
                  from,
                  style: const TextStyle(
                    color: AppColors.avoid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('→', style: TextStyle(fontSize: 20))),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('إلى', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                Text(
                  to,
                  style: const TextStyle(
                    color: AppColors.preferred,
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
