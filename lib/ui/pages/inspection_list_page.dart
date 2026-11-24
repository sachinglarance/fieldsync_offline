import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/inspection.dart';
import '../../viewmodels/inspection_list_view_model.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/sync_status_chip.dart';
import 'inspection_form_page.dart';

class InspectionListPage extends StatelessWidget {
  const InspectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InspectionListViewModel>();
    final message = vm.message;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        vm.clearMessage();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldSync'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: vm.isOnline && !vm.isSyncing ? vm.sync : null,
            icon: vm.isSyncing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Badge.count(
                    count: vm.unsyncedCount,
                    isLabelVisible: vm.unsyncedCount > 0,
                    child: const Icon(Icons.sync),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectivityBanner(isOnline: vm.isOnline, unsynced: vm.unsyncedCount),
          Expanded(
            child: vm.items.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: vm.items.length,
                    itemBuilder: (context, i) =>
                        _InspectionTile(item: vm.items[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<Inspection>(
            MaterialPageRoute(builder: (_) => const InspectionFormPage()),
          );
          if (created != null) await vm.save(created);
        },
        icon: const Icon(Icons.add),
        label: const Text('New report'),
      ),
    );
  }
}

class _InspectionTile extends StatelessWidget {
  const _InspectionTile({required this.item});
  final Inspection item;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<InspectionListViewModel>();
    final date = DateFormat('d MMM, HH:mm').format(item.createdAt);
    return Dismissible(
      key: ValueKey(item.id),
      direction: item.syncStatus == SyncStatus.synced
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => vm.delete(item),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconFor(item.type))),
        title: Text(item.siteName),
        subtitle: Text(
          '${item.type.label} · ${item.condition.label} · $date'
          '${item.lastError != null ? '\n${item.lastError}' : ''}',
        ),
        isThreeLine: item.lastError != null,
        trailing: item.syncStatus == SyncStatus.failed
            ? TextButton(
                onPressed: () => vm.retry(item),
                child: const Text('Retry'),
              )
            : SyncStatusChip(status: item.syncStatus),
      ),
    );
  }

  static IconData _iconFor(InspectionType t) => switch (t) {
    InspectionType.installation => Icons.build_circle_outlined,
    InspectionType.assessment => Icons.groups_outlined,
    InspectionType.maintenance => Icons.water_drop_outlined,
  };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No reports yet.\nTap "New report". It works without internet and syncs automatically when you are back online.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
