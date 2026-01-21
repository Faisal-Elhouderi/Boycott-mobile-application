import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final bool hasAlternatives;
  final int alternativesCount;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    required this.hasAlternatives,
    required this.alternativesCount,
  });
}

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final MapController _mapController = MapController();
  bool _isMapView = true;
  String _selectedCity = 'الكل';
  bool _showOnlyWithAlternatives = false;
  Store? _selectedStore;

  final List<String> _cities = ['الكل', 'طرابلس', 'بنغازي', 'مصراتة'];

  final List<Store> _stores = [
    Store(
      id: '1',
      name: 'سوبر ماركت الريادة',
      address: 'شارع الجمهورية، طرابلس',
      city: 'طرابلس',
      lat: 32.8872,
      lng: 13.1913,
      hasAlternatives: true,
      alternativesCount: 15,
    ),
    Store(
      id: '2',
      name: 'متجر الأمل',
      address: 'منطقة السراج، طرابلس',
      city: 'طرابلس',
      lat: 32.8752,
      lng: 13.1763,
      hasAlternatives: true,
      alternativesCount: 8,
    ),
    Store(
      id: '3',
      name: 'سوبر ماركت النجمة',
      address: 'شارع عمر المختار، بنغازي',
      city: 'بنغازي',
      lat: 32.1194,
      lng: 20.0868,
      hasAlternatives: true,
      alternativesCount: 12,
    ),
    Store(
      id: '4',
      name: 'متجر السلام',
      address: 'منطقة الحدائق، بنغازي',
      city: 'بنغازي',
      lat: 32.1094,
      lng: 20.0768,
      hasAlternatives: false,
      alternativesCount: 0,
    ),
    Store(
      id: '5',
      name: 'سوبر ماركت الوحدة',
      address: 'وسط المدينة، مصراتة',
      city: 'مصراتة',
      lat: 32.3754,
      lng: 15.0925,
      hasAlternatives: true,
      alternativesCount: 6,
    ),
  ];

  List<Store> get _filteredStores {
    return _stores.where((store) {
      if (_selectedCity != 'الكل' && store.city != _selectedCity) return false;
      if (_showOnlyWithAlternatives && !store.hasAlternatives) return false;
      return true;
    }).toList();
  }

  void _openInMaps(Store store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${store.lat},${store.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showStoreDetails(Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StoreDetailsSheet(
        store: store,
        onOpenMaps: () => _openInMaps(store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المتاجر'),
        actions: [
          // View toggle
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggleButton(
                  icon: Icons.map_outlined,
                  isSelected: _isMapView,
                  onTap: () => setState(() => _isMapView = true),
                ),
                _ViewToggleButton(
                  icon: Icons.list_rounded,
                  isSelected: !_isMapView,
                  onTap: () => setState(() => _isMapView = false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // City dropdown
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
                                child: Text(city),
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
                    // Toggle
                    Row(
                      children: [
                        Switch(
                          value: _showOnlyWithAlternatives,
                          onChanged: (value) {
                            setState(() => _showOnlyWithAlternatives = value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        const Text(
                          'مع بدائل',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عرض ${_filteredStores.length} متجر',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add store
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة متجر'),
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(32.4, 17.0), // Libya center
        initialZoom: 6,
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
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedStore = store);
                  _showStoreDetails(store);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: store.hasAlternatives
                        ? AppColors.preferred
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (store.hasAlternatives
                                ? AppColors.preferred
                                : AppColors.primary)
                            .withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_filteredStores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔍', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'لا توجد متاجر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'جرب تغيير المرشحات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = _filteredStores[index];
        return _StoreCard(
          store: store,
          onTap: () => _showStoreDetails(store),
          onDirections: () => _openInMaps(store),
        );
      },
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
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
  final Store store;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _StoreCard({
    required this.store,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: store.hasAlternatives
                      ? AppColors.preferredLight
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: store.hasAlternatives
                      ? AppColors.preferred
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            store.city,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        if (store.hasAlternatives) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.preferredLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${store.alternativesCount} بديل',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.preferred,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('اتجاهات'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreDetailsSheet extends StatelessWidget {
  final Store store;
  final VoidCallback onOpenMaps;

  const _StoreDetailsSheet({
    required this.store,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Store info
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: store.hasAlternatives
                          ? AppColors.preferredLight
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      size: 28,
                      color: store.hasAlternatives
                          ? AppColors.preferred
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(icon: Icons.location_city, label: store.city),
                  if (store.hasAlternatives)
                    _InfoChip(
                      icon: Icons.check_circle,
                      label: '${store.alternativesCount} بديل متوفر',
                      isHighlighted: true,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onOpenMaps();
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('فتح في الخرائط'),
                    ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.preferredLight : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? AppColors.preferred : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlighted ? AppColors.preferred : AppColors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

