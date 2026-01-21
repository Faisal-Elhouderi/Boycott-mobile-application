import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => context.push('/debug'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.homeTagline,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.mainSections,
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
            children: [
              _HomeCard(
                icon: Icons.inventory_2_outlined,
                label: l10n.products,
                onTap: () => context.push('/products'),
              ),
              _HomeCard(
                icon: Icons.swap_horiz,
                label: l10n.alternatives,
                onTap: () => context.push('/alternatives'),
              ),
              _HomeCard(
                icon: Icons.apartment,
                label: l10n.companies,
                onTap: () => context.push('/companies'),
              ),
              _HomeCard(
                icon: Icons.people_outline,
                label: l10n.community,
                onTap: () => context.push('/community'),
              ),
              _HomeCard(
                icon: Icons.person_outline,
                label: l10n.profile,
                onTap: () => context.push('/profile'),
              ),
              _HomeCard(
                icon: Icons.storefront,
                label: l10n.markets,
                onTap: () => context.push('/markets'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.tools,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HomeCard(
                  icon: Icons.report_outlined,
                  label: l10n.submitReport,
                  onTap: () => context.push('/reports'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HomeCard(
                  icon: Icons.bug_report_outlined,
                  label: l10n.apiDebug,
                  onTap: () => context.push('/debug'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
