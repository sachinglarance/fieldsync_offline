import 'package:flutter/material.dart';

import '../../models/inspection.dart';

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key, required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status) {
      SyncStatus.synced => (Icons.cloud_done, 'Synced', Colors.green),
      SyncStatus.pending => (
        Icons.cloud_upload_outlined,
        'Pending',
        Colors.orange,
      ),
      SyncStatus.syncing => (Icons.sync, 'Syncing', Colors.blue),
      SyncStatus.failed => (Icons.cloud_off, 'Failed', Colors.red),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
