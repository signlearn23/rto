import 'package:flutter/material.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/driving_school_model.dart';
import '../../../data/repositories/driving_school_repository.dart';

/// Plain form for user-contributed driving school details.
/// No maps/location-picker dependency - location is free text as requested.
class DrivingSchoolFormScreen extends StatefulWidget {
  const DrivingSchoolFormScreen({super.key});

  @override
  State<DrivingSchoolFormScreen> createState() => _DrivingSchoolFormScreenState();
}

class _DrivingSchoolFormScreenState extends State<DrivingSchoolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = DrivingSchoolRepository();

  final _name = TextEditingController();
  final _location = TextEditingController();
  final _timing = TextEditingController();
  final _cost = TextEditingController();
  final _contact = TextEditingController();
  String _type = 'Car';

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _timing.dispose();
    _cost.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final school = DrivingSchoolModel(
      id: generateSimpleId(),
      name: _name.text.trim(),
      type: _type,
      location: _location.text.trim(),
      timing: _timing.text.trim(),
      cost: _cost.text.trim(),
      contact: _contact.text.trim(),
      submittedAt: DateTime.now(),
    );
    await _repo.submit(school);

    setState(() => _submitting = false);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text(
            'Your driving school details have been submitted. They will appear after review.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Driving School')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Know a good driving school? Share the details to help other learners.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'School Name', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: const ['Car', 'Bike', 'Both']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? 'Car'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Location / Address',
                hintText: 'Area, city (free text — no map required)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timing,
              decoration: const InputDecoration(
                labelText: 'Timing',
                hintText: 'e.g. Mon-Sat, 7 AM - 7 PM',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cost,
              decoration: const InputDecoration(
                labelText: 'Approx. Cost',
                hintText: 'e.g. ₹4,000 for 10 classes',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contact,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 8) return 'Enter a valid contact number';
                return null;
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
