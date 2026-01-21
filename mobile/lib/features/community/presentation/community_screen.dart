import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/search_input.dart';
import '../data/community_repository.dart';
import '../models/community_suggestion.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(communitySearchProvider.notifier).state = value;
    setState(() {});
  }

  Future<void> _submitSuggestion() async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);

    if (!authState.isLoggedIn) {
      _showSnack(l10n.loginRequired);
      return;
    }

    if (_textController.text.trim().isEmpty) {
      setState(() => _submitError = l10n.suggestionTextRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final repository = ref.read(communityRepositoryProvider);
      await repository.createSuggestion(
        text: _textController.text.trim(),
        companyName: _companyController.text.trim(),
      );
      if (!mounted) return;
      _textController.clear();
      _companyController.clear();
      _showSnack(l10n.submitSuccess);
      ref.invalidate(communitySuggestionsProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = l10n.submitFailed);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final suggestionsAsync = ref.watch(communitySuggestionsProvider);
    final sort = ref.watch(communitySortProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.community),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(communitySuggestionsProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchInput(
            controller: _searchController,
            hintText: l10n.searchCommunityHint,
            onChanged: _onSearchChanged,
            onSubmitted: () => ref.invalidate(communitySuggestionsProvider),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text(l10n.sortTop),
                  selected: sort == 'top',
                  onSelected: (_) {
                    ref.read(communitySortProvider.notifier).state = 'top';
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Text(l10n.sortNew),
                  selected: sort == 'new',
                  onSelected: (_) {
                    ref.read(communitySortProvider.notifier).state = 'new';
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!authState.isLoggedIn)
            _LoginPrompt(l10n: l10n)
          else
            _SuggestionForm(
              l10n: l10n,
              textController: _textController,
              companyController: _companyController,
              isSubmitting: _isSubmitting,
              submitError: _submitError,
              onSubmit: _submitSuggestion,
            ),
          const SizedBox(height: 20),
          Text(
            l10n.communitySuggestions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          suggestionsAsync.when(
            data: (items) => _SuggestionsList(items: items),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorState(
              title: l10n.error,
              message: l10n.communityLoadFailed,
              actionLabel: l10n.retry,
              onRetry: () => ref.invalidate(communitySuggestionsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final AppLocalizations l10n;

  const _LoginPrompt({required this.l10n});

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
            l10n.signInToParticipate,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
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
    );
  }
}

class _SuggestionForm extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController textController;
  final TextEditingController companyController;
  final bool isSubmitting;
  final String? submitError;
  final VoidCallback onSubmit;

  const _SuggestionForm({
    required this.l10n,
    required this.textController,
    required this.companyController,
    required this.isSubmitting,
    required this.submitError,
    required this.onSubmit,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addSuggestion,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.suggestionText,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: companyController,
            decoration: InputDecoration(
              labelText: l10n.companyOptional,
            ),
          ),
          const SizedBox(height: 12),
          if (submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                submitError!,
                style: const TextStyle(color: AppColors.avoid, fontSize: 12),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(l10n.submit),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends ConsumerWidget {
  final List<CommunitySuggestion> items;

  const _SuggestionsList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    if (items.isEmpty) {
      return _EmptyState(
        title: l10n.noSuggestionsTitle,
        subtitle: l10n.noSuggestionsSubtitle,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
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
                item.displayText,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (item.companyName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.companyName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    item.authorName.isNotEmpty
                        ? item.authorName
                        : l10n.anonymousUser,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      if (!authState.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.loginRequired)),
                        );
                        return;
                      }
                      final repository =
                          ref.read(communityRepositoryProvider);
                      await repository.toggleLike(item.id);
                      ref.invalidate(communitySuggestionsProvider);
                    },
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    label: Text('${item.likesCount}'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 48, color: AppColors.border),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
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
    );
  }
}
