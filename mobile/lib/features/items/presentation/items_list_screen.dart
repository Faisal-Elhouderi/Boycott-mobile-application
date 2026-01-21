import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/items_repository.dart';
import '../models/item.dart';

class ItemsListScreen extends ConsumerStatefulWidget {
  const ItemsListScreen({super.key});

  @override
  ConsumerState<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends ConsumerState<ItemsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.items),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(itemsProvider),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => _buildContent(context, items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: l10n.error,
          message: '${l10n.itemsLoadFailed}\n${error.toString()}',
          actionLabel: l10n.retry,
          onRetry: () => ref.invalidate(itemsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Item> items) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _EmptyState(
        title: l10n.noItemsTitle,
        subtitle: l10n.noItemsSubtitle,
        actionLabel: l10n.refresh,
        onRefresh: () => ref.invalidate(itemsProvider),
      );
    }

    final categories = _extractCategories(items);
    final filteredItems = _applyFilters(items);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchItemsHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        if (categories.isNotEmpty)
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = isSelected ? null : category;
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(itemsProvider),
            child: filteredItems.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 80),
                      const Icon(Icons.inbox_outlined, size: 48, color: AppColors.border),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noMatchingItemsTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.noMatchingItemsSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final canOpen = item.id != null && item.id!.isNotEmpty;
                      return _ItemCard(
                        item: item,
                        onTap: canOpen ? () => context.push('/items/${item.id}') : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<String> _extractCategories(List<Item> items) {
    final categories = items
        .map((item) => item.category)
        .whereType<String>()
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  List<Item> _applyFilters(List<Item> items) {
    final query = _searchQuery.trim().toLowerCase();
    return items.where((item) {
      final matchesCategory = _selectedCategory == null ||
          item.category?.toLowerCase() == _selectedCategory?.toLowerCase();
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;

      final haystack = [
        item.name,
        item.category,
        item.description,
        item.status,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: onTap == null ? AppColors.textSecondary : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description?.trim().isNotEmpty == true
                          ? item.description!
                          : (item.category?.isNotEmpty == true
                              ? item.category!
                              : l10n.noDescription),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (item.status != null && item.status!.isNotEmpty)
                _StatusPill(label: item.status!),
              if (onTap == null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.lock_outline, size: 18, color: AppColors.textTertiary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'avoid':
        return AppColors.avoid;
      case 'preferred':
        return AppColors.preferred;
      case 'caution':
        return AppColors.caution;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onRefresh;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
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
