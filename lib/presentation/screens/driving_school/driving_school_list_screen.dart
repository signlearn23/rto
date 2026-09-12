import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../../data/models/driving_school_model.dart';
import '../../../data/repositories/driving_school_repository.dart';
import '../../providers/app_state_provider.dart';
import 'driving_school_detail_screen.dart';

const _bg = Color(0xFF0F1115);
const _card = Color(0xFF1C1F26);
const _accent = Color(0xFFFFD400);

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
  String _serviceFilter = 'All';
  String _areaLabel = '';

  static const int _adEveryN = 5;
  static const _serviceOptions = [
    'All',
    'Motor Training Schools For Two Wheeler',
    'Motor Training Schools For Heavy Vehicle',
    'Motor Training Schools For Auto Rickshaw',
  ];

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
      serviceFilter: _serviceFilter,
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

  List<_Row> get _rows {
    final rows = <_Row>[];
    var since = 0, slot = 0;
    for (final s in _schools) {
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
    final rows = _rows;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Driving Schools', style: TextStyle(fontSize: 18)),
            if (_areaLabel.isNotEmpty)
              Text(_areaLabel, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _serviceFilter,
              dropdownColor: _card,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: _serviceOptions
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s == 'All' ? 'All' : s.replaceFirst('Motor Training Schools For ', ''),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _serviceFilter = v);
                _load();
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
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
                      color: _card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _load(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search by Name or Area',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    icon: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, color: _accent),
                    onPressed: _locating ? null : _useMyLocation,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                    ? const Center(
                        child: Text('No driving schools found', style: TextStyle(color: Colors.grey)))
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

class _SchoolCard extends StatelessWidget {
  final DrivingSchool school;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const _SchoolCard({required this.school, required this.onTap, required this.onBookmarkToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14)),
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
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.phone, size: 15, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(school.phoneNumbers.join(', '),
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 15, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${school.address}, ${school.area} - ${school.pincode}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                      color: school.isBookmarked ? _accent : Colors.grey,
                    ),
                    onPressed: onBookmarkToggle,
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
