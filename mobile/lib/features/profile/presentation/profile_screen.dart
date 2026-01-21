import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';
import '../models/profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!authState.isLoggedIn) {
      return _GuestProfile(l10n: l10n);
    }

    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: profileAsync.when(
        data: (profile) => _UserProfile(profile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: l10n.error,
          message: l10n.profileLoadFailed,
          actionLabel: l10n.retry,
          onRetry: () => ref.invalidate(profileProvider),
        ),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  final AppLocalizations l10n;

  const _GuestProfile({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👤', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                l10n.loginToContinue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.profileLoginHint,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: Text(l10n.login),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/register'),
                    child: Text(l10n.register),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfile extends ConsumerWidget {
  final ProfileSummary profile;

  const _UserProfile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = profile.user;
    final activities = profile.activities;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.yourActivity,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: activities.reports.toString(),
                label: l10n.reports,
                color: AppColors.caution,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: activities.suggestions.toString(),
                label: l10n.communitySuggestions,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: activities.likesGiven.toString(),
                label: l10n.likesGiven,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: user.id.isNotEmpty ? '100%' : '--',
                label: l10n.profileComplete,
                color: AppColors.preferred,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.avoid,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
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
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
