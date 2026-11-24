/// The inspection record that field teams save, with its enums, sync state and
/// row and JSON mapping.
enum InspectionType {
  installation('Installation'),
  assessment('Community assessment'),
  maintenance('Maintenance');

  const InspectionType(this.label);
  final String label;
}

enum PumpCondition {
  working('Working'),
  needsRepair('Needs repair'),
  broken('Broken');

  const PumpCondition(this.label);
  final String label;
}

/// Where a record is in the outbox. Everything starts as [pending] and is
/// only ever written locally first; the sync engine moves it on.
enum SyncStatus { pending, syncing, synced, failed }

class Inspection {
  const Inspection({
    required this.id,
    required this.siteName,
    required this.inspectorName,
    required this.type,
    required this.condition,
    required this.flowRateLpm,
    required this.householdsServed,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.attempts = 0,
    this.nextRetryAt,
    this.lastError,
    this.remoteId,
  });

  final String
  id; // client-generated UUID, so records exist before the server sees them
  final String siteName;
  final String inspectorName;
  final InspectionType type;
  final PumpCondition condition;
  final double flowRateLpm;
  final int householdsServed;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final int attempts;
  final DateTime? nextRetryAt;
  final String? lastError;
  final int? remoteId;

  Inspection copyWith({
    SyncStatus? syncStatus,
    int? attempts,
    DateTime? Function()? nextRetryAt,
    String? Function()? lastError,
    int? remoteId,
    DateTime? updatedAt,
  }) => Inspection(
    id: id,
    siteName: siteName,
    inspectorName: inspectorName,
    type: type,
    condition: condition,
    flowRateLpm: flowRateLpm,
    householdsServed: householdsServed,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    attempts: attempts ?? this.attempts,
    nextRetryAt: nextRetryAt != null ? nextRetryAt() : this.nextRetryAt,
    lastError: lastError != null ? lastError() : this.lastError,
    remoteId: remoteId ?? this.remoteId,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'site_name': siteName,
    'inspector_name': inspectorName,
    'type': type.name,
    'condition': condition.name,
    'flow_rate_lpm': flowRateLpm,
    'households_served': householdsServed,
    'notes': notes,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'sync_status': syncStatus.name,
    'attempts': attempts,
    'next_retry_at': nextRetryAt?.millisecondsSinceEpoch,
    'last_error': lastError,
    'remote_id': remoteId,
  };

  factory Inspection.fromRow(Map<String, Object?> row) {
    DateTime? date(Object? v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch(v as int);
    return Inspection(
      id: row['id'] as String,
      siteName: row['site_name'] as String,
      inspectorName: row['inspector_name'] as String,
      type: InspectionType.values.byName(row['type'] as String),
      condition: PumpCondition.values.byName(row['condition'] as String),
      flowRateLpm: (row['flow_rate_lpm'] as num).toDouble(),
      householdsServed: row['households_served'] as int,
      notes: row['notes'] as String,
      createdAt: date(row['created_at'])!,
      updatedAt: date(row['updated_at'])!,
      syncStatus: SyncStatus.values.byName(row['sync_status'] as String),
      attempts: row['attempts'] as int,
      nextRetryAt: date(row['next_retry_at']),
      lastError: row['last_error'] as String?,
      remoteId: row['remote_id'] as int?,
    );
  }

  /// Payload sent to the web application.
  Map<String, Object?> toApiJson() => {
    'clientId': id,
    'siteName': siteName,
    'inspector': inspectorName,
    'type': type.name,
    'condition': condition.name,
    'flowRateLpm': flowRateLpm,
    'householdsServed': householdsServed,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
