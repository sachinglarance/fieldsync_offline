import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/inspection.dart';

/// Holds form state and validation rules so they can be unit-tested
/// without building widgets.
class InspectionFormViewModel extends ChangeNotifier {
  InspectionFormViewModel({DateTime Function()? clock, Uuid? uuid})
    : _now = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid();

  final DateTime Function() _now;
  final Uuid _uuid;

  InspectionType type = InspectionType.maintenance;
  PumpCondition condition = PumpCondition.working;

  void setType(InspectionType value) {
    type = value;
    notifyListeners();
  }

  void setCondition(PumpCondition value) {
    condition = value;
    notifyListeners();
  }

  /// Notes are mandatory when a pump isn't working, so the repair team knows
  /// what to bring.
  bool get notesRequired => condition != PumpCondition.working;

  String? validateRequired(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  String? validateFlowRate(String? v) {
    final n = double.tryParse(v?.trim() ?? '');
    if (n == null) return 'Enter a number';
    if (n < 0 || n > 500) return 'Must be between 0 and 500 L/min';
    return null;
  }

  String? validateHouseholds(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  String? validateNotes(String? v) =>
      notesRequired && (v == null || v.trim().length < 10)
      ? 'Describe the problem (min 10 characters)'
      : null;

  Inspection build({
    required String siteName,
    required String inspectorName,
    required String flowRate,
    required String households,
    required String notes,
  }) {
    final now = _now();
    return Inspection(
      id: _uuid.v4(),
      siteName: siteName.trim(),
      inspectorName: inspectorName.trim(),
      type: type,
      condition: condition,
      flowRateLpm: double.parse(flowRate.trim()),
      householdsServed: int.parse(households.trim()),
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }
}
