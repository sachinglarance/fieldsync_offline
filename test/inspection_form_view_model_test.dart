import 'package:fieldsync_offline/models/inspection.dart';
import 'package:fieldsync_offline/viewmodels/inspection_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final vm = InspectionFormViewModel();

  test('flow rate must be a number in range', () {
    expect(vm.validateFlowRate('abc'), isNotNull);
    expect(vm.validateFlowRate('-1'), isNotNull);
    expect(vm.validateFlowRate('12.5'), isNull);
  });

  test('notes are required only when the pump is not working', () {
    final vm = InspectionFormViewModel();
    expect(vm.validateNotes(''), isNull);
    vm.setCondition(PumpCondition.broken);
    expect(vm.validateNotes('short'), isNotNull);
    expect(vm.validateNotes('Cylinder seal is worn out'), isNull);
  });

  test('build creates a pending record with a UUID and trimmed values', () {
    final item = vm.build(
      siteName: ' Kottur ',
      inspectorName: 'Ravi',
      flowRate: '8',
      households: '30',
      notes: '',
    );
    expect(item.siteName, 'Kottur');
    expect(item.syncStatus, SyncStatus.pending);
    expect(item.id, hasLength(36));
  });
}
