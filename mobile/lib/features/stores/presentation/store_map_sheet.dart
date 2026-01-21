import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class StoreInfo {
  final String id;
  final String name;
  final String nameAr;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final double? priceMin;
  final double? priceMax;
  final String currency;
  final String? lastConfirmed;

  StoreInfo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    this.priceMin,
    this.priceMax,
    this.currency = 'د.ل',
    this.lastConfirmed,
  });
}

class StoreMapSheet extends StatefulWidget {
  final String productName;
  final List<StoreInfo> stores;

  const StoreMapSheet({
    super.key,
    required this.productName,
    required this.stores,
  });

  static Future<void> show(
    BuildContext context, {
    required String productName,
    required List<StoreInfo> stores,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreMapSheet(
        productName: productName,
        stores: stores,
      ),
    );
  }

  @override
  State<StoreMapSheet> createState() => _StoreMapSheetState();
}

class _StoreMapSheetState extends State<StoreMapSheet> {
  bool _isMapView = true;
  String _selectedCity = 'الكل';
  StoreInfo? _selectedStore;

  List<String> get _cities {
    final uniqueCities = widget.stores.map((s) => s.city).toSet().toList();
    return ['الكل', ...uniqueCities];
  }

  List<StoreInfo> get _filteredStores {
    if (_selectedCity == 'الكل') return widget.stores;
    return widget.stores.where((s) => s.city == _selectedCity).toList();
  }

  void _openInMaps(StoreInfo store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${store.lat},${store.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أين أجد هذا المنتج؟',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCity,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                items: _cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedCity = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ViewToggle(
                                icon: Icons.map_outlined,
                                isSelected: _isMapView,
                                onTap: () => setState(() => _isMapView = true),
                              ),
                              _ViewToggle(
                                icon: Icons.list_rounded,
                                isSelected: !_isMapView,
                                onTap: () => setState(() => _isMapView = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'عدد المتاجر: ${_filteredStores.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredStores.isEmpty
                    ? _buildEmptyState()
                    : _isMapView
                        ? _buildMapView()
                        : _buildListView(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'لا توجد متاجر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'جرّب اختيار مدينة أخرى.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _filteredStores.isNotEmpty
            ? LatLng(_filteredStores.first.lat, _filteredStores.first.lng)
            : const LatLng(32.4, 17.0),
        initialZoom: _filteredStores.length == 1 ? 13 : 6,
        onTap: (_, __) => setState(() => _selectedStore = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boycott.boycott_app',
        ),
        MarkerLayer(
          markers: _filteredStores.map((store) {
            final isSelected = _selectedStore?.id == store.id;
            return Marker(
              point: LatLng(store.lat, store.lng),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => setState(() => _selectedStore = store),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.preferred,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.preferred.withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedStore != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StoreCardOverlay(
              store: _selectedStore!,
              onDirections: () => _openInMaps(_selectedStore!),
              onClose: () => setState(() => _selectedStore = null),
            ),
          ),
      ],
    );
  }

  Widget _buildListView(ScrollController scrollController) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = _filteredStores[index];
        return _StoreCard(
          store: store,
          onDirections: () => _openInMaps(store),
        );
      },
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreInfo store;
  final VoidCallback onDirections;

  const _StoreCard({
    required this.store,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
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
            child: const Icon(
              Icons.store_rounded,
              color: AppColors.preferred,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.nameAr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${store.address} - ${store.city}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (store.priceMin != null && store.priceMax != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${store.priceMin} - ${store.priceMax} ${store.currency}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.preferred,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onDirections,
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('اتجاهات'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreCardOverlay extends StatelessWidget {
  final StoreInfo store;
  final VoidCallback onDirections;
  final VoidCallback onClose;

  const _StoreCardOverlay({
    required this.store,
    required this.onDirections,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.preferredLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: AppColors.preferred),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.nameAr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${store.address} - ${store.city}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
            ],
          ),
          if (store.priceMin != null && store.priceMax != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.preferredLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${store.priceMin} - ${store.priceMax} ${store.currency}',
                style: const TextStyle(
                  color: AppColors.preferred,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.directions),
              label: const Text('فتح في الخرائط'),
            ),
          ),
        ],
      ),
    );
  }
}
