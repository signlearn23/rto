import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/state_language_map.dart';
import '../../providers/app_state_provider.dart';
import 'select_language_screen.dart';

class SelectStateScreen extends StatefulWidget {
  const SelectStateScreen({super.key});

  @override
  State<SelectStateScreen> createState() => _SelectStateScreenState();
}

class _SelectStateScreenState extends State<SelectStateScreen> {
  String? _selected;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final states = StateLanguageMap.all
        .where((s) => s.displayName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your State')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search state',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: states.length,
              itemBuilder: (context, index) {
                final state = states[index];
                final selected = state.code == _selected;
                return Card(
                  color: selected ? AppColors.primary.withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(state.displayName),
                    subtitle: Text(state.languages.map((l) => l.displayName).join(' • ')),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.chevron_right),
                    onTap: () => setState(() => _selected = state.code),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () {
                        context.read<AppStateProvider>().setState(_selected!);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SelectLanguageScreen(stateCode: _selected!),
                        ));
                      },
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
