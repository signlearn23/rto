import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../../data/models/driving_school_model.dart';
import '../../providers/app_state_provider.dart';

const _bg = Color(0xFF0F1115);
const _accent = Color(0xFFFFD400);

class DrivingSchoolDetailScreen extends StatefulWidget {
  final DrivingSchool school;
  const DrivingSchoolDetailScreen({super.key, required this.school});

  @override
  State<DrivingSchoolDetailScreen> createState() => _DrivingSchoolDetailScreenState();
}

class _DrivingSchoolDetailScreenState extends State<DrivingSchoolDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    final s = widget.school;
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(s.name, style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(
              s.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: s.isBookmarked ? _accent : Colors.white,
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
                  _sectionLabel('Phone Numbers'),
                  ...s.phoneNumbers.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(p, style: _valueStyle),
                      )),
                  const SizedBox(height: 20),
                  _sectionLabel('Address'),
                  RichText(
                    text: TextSpan(
                      style: _valueStyle,
                      children: [
                        TextSpan(text: '${s.address}, ${s.area} - ${s.pincode} '),
                        TextSpan(
                          text: '(View in Map)',
                          style: const TextStyle(color: _accent),
                          recognizer: TapGestureRecognizer()..onTap = _openMap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (s.services.isNotEmpty) ...[
                    _sectionLabel('Services'),
                    ...s.services.map((svc) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(svc, style: _valueStyle),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (s.email != null) ...[
                    _sectionLabel('Email'),
                    Text(s.email!, style: _valueStyle),
                    const SizedBox(height: 20),
                  ],
                  if (s.hoursOfOperation.isNotEmpty) ...[
                    Row(children: [
                      _sectionLabel('Hours of Operation'),
                      const SizedBox(width: 8),
                      Text(s.hoursOfOperation.keys.first,
                          style: const TextStyle(color: _accent, fontSize: 13)),
                      const Icon(Icons.arrow_drop_down, color: _accent, size: 18),
                    ]),
                    const SizedBox(height: 4),
                    Text('Today', style: _valueStyle.copyWith(color: Colors.grey)),
                    Text(s.hoursOfOperation.values.first, style: _valueStyle),
                    const SizedBox(height: 20),
                  ],
                  _sectionLabel('Mode of Payment'),
                  Text(s.paymentModes ?? 'Not mentioned', style: _valueStyle),
                ],
              ),
            ),
          ),
          if (s.phoneNumbers.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.black,
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

  Widget _sectionLabel(String text) =>
      Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(text, style: _labelStyle));

  static const _labelStyle = TextStyle(color: Colors.grey, fontSize: 13);
  static const _valueStyle = TextStyle(color: Colors.white, fontSize: 15);
}
