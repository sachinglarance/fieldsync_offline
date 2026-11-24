import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.isOnline,
    required this.unsynced,
  });
  final bool isOnline;
  final int unsynced;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      color: isOnline ? scheme.primaryContainer : scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(isOnline ? Icons.wifi : Icons.wifi_off, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOnline
                  ? (unsynced == 0
                        ? 'Online · all records synced'
                        : 'Online · $unsynced waiting to sync')
                  : 'Offline · records are saved on this device ($unsynced unsynced)',
            ),
          ),
        ],
      ),
    );
  }
}
