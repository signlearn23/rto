import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../../data/models/driving_school_model.dart';
import '../../providers/app_state_provider.dart';

enum _HoursView { today, allWeek }

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class DrivingSchoolDetailScreen extends StatefulWidget {
  final DrivingSchool school;
  const DrivingSchoolDetailScreen({super.key, required this.school});

  @override
  State<DrivingSchoolDetailScreen> createState() => _DrivingSchoolDetailScreenState();
}

class _DrivingSchoolDetailScreenState extends State<DrivingSchoolDetailScreen> {
  _HoursView _hoursView = _HoursView.today;

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMap() async {
    final s = widget.school;
    final query = Uri.encodeComponent('${s.address}, ${s.area} ${s.pincode}');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Finds the key in [hours] matching today's actual weekday — matches
  /// either a full name ("Monday") or a 3-letter abbreviation ("Mon"),
  /// case-insensitively. Falls back to the first entry only if nothing
  /// matches (e.g. an unexpected key format), so it's still not blank.
  String? _todayKey(Map<String, String> hours) {
    final today = _weekdayNames[DateTime.now().weekday - 1]; // weekday: 1=Mon..7=Sun
    for (final key in hours.keys) {
      final k = key.toLowerCase();
      if (k == today.toLowerCase() || k == today.substring(0, 3).toLowerCase()) {
        return key;
      }
    }
    return hours.keys.isNotEmpty ? hours.keys.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.school;
    final appState = context.watch<AppStateProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
      title: Text(s.name, style: const TextStyle(fontSize: 17)),
      actions: [
       IconButton(
       icon: Icon(
         s.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
         color: s.isBookmarked ? AppColors.primary : null,
        ),
       onPressed: () => setState(() => s.isBookmarked = !s.isBookmarked),
       ),
     ],
   ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Phone Numbers', colorScheme),
                  ...s.phoneNumbers.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(p, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                      )),
                  const SizedBox(height: 20),
                  _sectionLabel('Address', colorScheme),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                      children: [
                        TextSpan(text: '${s.address}, ${s.area} - ${s.pincode} '),
                        TextSpan(
                          text: '(View in Map)',
                          style: const TextStyle(color: AppColors.primary),
                          recognizer: TapGestureRecognizer()..onTap = _openMap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (s.services.isNotEmpty) ...[
                    _sectionLabel('Services', colorScheme),
                    ...s.services.map((svc) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(svc, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (s.email != null) ...[
                    _sectionLabel('Email', colorScheme),
                    Text(s.email!, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                    const SizedBox(height: 20),
                  ],
                  if (s.hoursOfOperation.isNotEmpty) ...[
                    Row(
                      children: [
                        _sectionLabel('Hours of Operation', colorScheme),
                        const Spacer(),
                        _HoursToggle(
                          view: _hoursView,
                          onChanged: (v) => setState(() => _hoursView = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_hoursView == _HoursView.today) ...[
                      Builder(builder: (context) {
                        final key = _todayKey(s.hoursOfOperation);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today${key != null ? ' • $key' : ''}',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              key != null ? s.hoursOfOperation[key]! : 'Hours not available',
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                            ),
                          ],
                        );
                      }),
                    ] else
                      ...s.hoursOfOperation.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(e.key,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                                ),
                                Expanded(
                                  child: Text(e.value,
                                      style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 20),
                  ],
                  _sectionLabel('Mode of Payment', colorScheme),
                  Text(s.paymentModes ?? 'Not mentioned',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                ],
              ),
            ),
          ),
          if (s.phoneNumbers.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () => _call(s.phoneNumbers.first),
                icon: const Icon(Icons.call),
                label: const Text('CALL NOW', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          if (!appState.isAdsRemoved) const AdBanner(),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme colorScheme) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
      );
}

/// Small two-way "Today / All Week" toggle for the hours section.
class _HoursToggle extends StatelessWidget {
  final _HoursView view;
  final ValueChanged<_HoursView> onChanged;

  const _HoursToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(context, 'Today', _HoursView.today),
          _segment(context, 'All Week', _HoursView.allWeek),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, _HoursView value) {
    final selected = view == value;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
