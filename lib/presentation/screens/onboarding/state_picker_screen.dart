import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/state_language_map.dart';

/// Standalone state picker used from Settings ("Change State").
/// Pops with the selected state code, or null if dismissed without a pick.
class StatePickerScreen extends StatefulWidget {
  const StatePickerScreen({super.key, this.currentStateCode});

  final String? currentStateCode;

  @override
  State<StatePickerScreen> createState() => _StatePickerScreenState();
}

class _StatePickerScreenState extends State<StatePickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final states = StateLanguageMap.all
        .where((s) => s.displayName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Change State'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search state',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: states.isEmpty
                  ? Center(
                      child: Text('No states match "$_query"',
                          style: TextStyle(color: Colors.grey.shade500)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: states.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final state = states[index];
                        final selected = state.code == widget.currentStateCode;
                        return Material(
                          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(state.code),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? AppColors.primary : Colors.grey.shade200,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(state.displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                          color: selected ? AppColors.primary : Colors.black87,
                                        )),
                                  ),
                                  Icon(
                                    selected ? Icons.check_circle : Icons.chevron_right,
                                    color: selected ? AppColors.primary : Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
