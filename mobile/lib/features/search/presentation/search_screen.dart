import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _query = value);
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search,
                    size: 64,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.searchPlaceholder,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : _query.length < 2
              ? const SizedBox.shrink()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.products,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _SearchResult(
                      icon: '🥤',
                      title: 'كوكاكولا 330 مل',
                      subtitle: 'Coca-Cola',
                      verdict: 'AVOID',
                      onTap: () => context.push('/scan/5449000000996'),
                    ),
                    const SizedBox(height: 8),
                    _SearchResult(
                      icon: '🥤',
                      title: 'آر سي كولا 330 مل',
                      subtitle: 'RC Cola',
                      verdict: 'PREFERRED',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.brands,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _SearchResult(
                      icon: '🏢',
                      title: 'The Coca-Cola Company',
                      subtitle: '5 ${l10n.products}',
                      verdict: 'AVOID',
                      onTap: () => context.push('/company/coca-cola'),
                    ),
                  ],
                ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String verdict;
  final VoidCallback onTap;

  const _SearchResult({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.verdict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: verdict == 'AVOID'
                    ? AppColors.avoidLight
                    : verdict == 'PREFERRED'
                        ? AppColors.preferredLight
                        : AppColors.unknownLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                verdict == 'AVOID' ? '🚫' : verdict == 'PREFERRED' ? '✅' : '❔',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
