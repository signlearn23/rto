import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../../data/models/driving_school_model.dart';
import '../../../data/repositories/driving_school_repository.dart';
import '../../providers/app_state_provider.dart';
import 'driving_school_detail_screen.dart';

enum _SchoolFilter { all, bookmarked }

sealed class _Row {}
class _SchoolRow extends _Row {
  final DrivingSchool school;
  _SchoolRow(this.school);
}
class _AdRow extends _Row {
  final int slot;
  _AdRow(this.slot);
}

class DrivingSchoolListScreen extends StatefulWidget {
  const DrivingSchoolListScreen({super.key});

  @override
  State<DrivingSchoolListScreen> createState() => _DrivingSchoolListScreenState();
}

class _DrivingSchoolListScreenState extends State<DrivingSchoolListScreen> {
  final _repo = DrivingSchoolRepository();
  final _searchController = TextEditingController();
  final Map<int, NativeAd> _ads = {};
  final Set<int> _adLoaded = {};

  List<DrivingSchool> _schools = [];
  bool _loading = true;
  bool _locating = false;
  _SchoolFilter _filter = _SchoolFilter.all;
  String _areaLabel = '';

  static const int _adEveryN = 5;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _areaLabel = appState.selectedState ?? '';
    _load();
  }

  Future<void> _load({double? lat, double? lng}) async {
    final appState = context.read<AppStateProvider>();
    setState(() => _loading = true);
    final results = await _repo.search(
      stateCode: appState.selectedState ?? 'tamilnadu',
      query: _searchController.text,
      // Service-type filtering was removed from the UI (All/Bookmarked
      // only now), so this always requests the unfiltered set; bookmarked
      // narrows the list client-side below instead.
      serviceFilter: 'All',
      nearLat: lat,
      nearLng: lng,
    );
    setState(() {
      _schools = results;
      _loading = false;
    });
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Location permission denied')));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      await _load(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not fetch location')));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  List<DrivingSchool> get _visibleSchools {
    if (_filter == _SchoolFilter.bookmarked) {
      return _schools.where((s) => s.isBookmarked).toList();
    }
    return _schools;
  }

  List<_Row> get _rows {
    final rows = <_Row>[];
    var since = 0, slot = 0;
    for (final s in _visibleSchools) {
      rows.add(_SchoolRow(s));
      if (++since == _adEveryN) {
        rows.add(_AdRow(slot++));
        since = 0;
      }
    }
    return rows;
  }

  NativeAd _adFor(int slot) {
    return _ads.putIfAbsent(slot, () {
      final ad = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110', // TODO: real native ad unit id
        factoryId: 'advancedNativeAd',
        listener: NativeAdListener(
          onAdLoaded: (_) => setState(() => _adLoaded.add(slot)),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _ads.remove(slot);
          },
        ),
        request: const AdRequest(),
      )..load();
      return ad;
    });
  }

  @override
  void dispose() {
    for (final ad in _ads.values) ad.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final rows = _rows;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Driving Schools', style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
            if (_areaLabel.isNotEmpty)
              Text(_areaLabel, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: colorScheme.onSurface),
                      onSubmitted: (_) => _load(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                        hintText: 'Search by Name or Area',
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, color: AppColors.primary),
                    onPressed: _locating ? null : _useMyLocation,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == _SchoolFilter.all,
                  onTap: () => setState(() => _filter = _SchoolFilter.all),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Bookmarked',
                  selected: _filter == _SchoolFilter.bookmarked,
                  onTap: () => setState(() => _filter = _SchoolFilter.bookmarked),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                    ? Center(
                        child: Text(
                          _filter == _SchoolFilter.bookmarked
                              ? 'No bookmarked schools yet'
                              : 'No driving schools found',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final row = rows[i];
                          if (row is _AdRow) {
                            final ad = _ads[row.slot] ?? _adFor(row.slot);
                            final loaded = _adLoaded.contains(row.slot);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              height: loaded ? 260 : 0,
                              child: loaded ? AdWidget(ad: ad) : null,
                            );
                          }
                          final school = (row as _SchoolRow).school;
                          return _SchoolCard(
                            school: school,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DrivingSchoolDetailScreen(school: school)),
                            ),
                            onBookmarkToggle: () => setState(() => school.isBookmarked = !school.isBookmarked),
                          );
                        },
                      ),
          ),
          if (!appState.isAdsRemoved) const AdBanner(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: AppColors.primary.withOpacity(0.18),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? AppColors.primary : colorScheme.outlineVariant),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final DrivingSchool school;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const _SchoolCard({required this.school, required this.onTap, required this.onBookmarkToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(school.name,
                        style: TextStyle(
                            color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.phone, size: 15, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(school.phoneNumbers.join(', '),
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 15, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${school.address}, ${school.area} - ${school.pincode}',
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      school.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: school.isBookmarked ? AppColors.primary : colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onBookmarkToggle,
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
