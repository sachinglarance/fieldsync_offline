import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/inspection.dart';
import '../../viewmodels/inspection_form_view_model.dart';

class InspectionFormPage extends StatelessWidget {
  const InspectionFormPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => InspectionFormViewModel(),
    child: const _InspectionForm(),
  );
}

class _InspectionForm extends StatefulWidget {
  const _InspectionForm();

  @override
  State<_InspectionForm> createState() => _InspectionFormState();
}

class _InspectionFormState extends State<_InspectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _site = TextEditingController();
  final _inspector = TextEditingController();
  final _flow = TextEditingController();
  final _households = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final c in [_site, _inspector, _flow, _households, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit(InspectionFormViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      vm.build(
        siteName: _site.text,
        inspectorName: _inspector.text,
        flowRate: _flow.text,
        households: _households.text,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InspectionFormViewModel>();
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<InspectionType>(
              segments: [
                for (final t in InspectionType.values)
                  ButtonSegment(
                    value: t,
                    label: Text(t.label, textAlign: TextAlign.center),
                  ),
              ],
              selected: {vm.type},
              onSelectionChanged: (s) => vm.setType(s.first),
            ),
            gap,
            TextFormField(
              key: const Key('site'),
              controller: _site,
              decoration: const InputDecoration(
                labelText: 'Site / village name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => vm.validateRequired(v, 'Site name'),
            ),
            gap,
            TextFormField(
              key: const Key('inspector'),
              controller: _inspector,
              decoration: const InputDecoration(
                labelText: 'Inspector',
                border: OutlineInputBorder(),
              ),
              validator: (v) => vm.validateRequired(v, 'Inspector'),
            ),
            gap,
            DropdownButtonFormField<PumpCondition>(
              initialValue: vm.condition,
              decoration: const InputDecoration(
                labelText: 'Pump condition',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in PumpCondition.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => vm.setCondition(c!),
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('flow'),
                    controller: _flow,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Flow rate (L/min)',
                      border: OutlineInputBorder(),
                    ),
                    validator: vm.validateFlowRate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('households'),
                    controller: _households,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Households served',
                      border: OutlineInputBorder(),
                    ),
                    validator: vm.validateHouseholds,
                  ),
                ),
              ],
            ),
            gap,
            TextFormField(
              key: const Key('notes'),
              controller: _notes,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: vm.notesRequired
                    ? 'Problem description *'
                    : 'Notes (optional)',
                border: const OutlineInputBorder(),
              ),
              validator: vm.validateNotes,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submit(vm),
              icon: const Icon(Icons.save),
              label: const Text('Save report'),
            ),
          ],
        ),
      ),
    );
  }
}
