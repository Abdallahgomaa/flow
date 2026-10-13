/// Outcome of `AuditService.verifyChain()` (P0-16).
///
/// Either the whole hash chain is intact, or the **first** broken link is
/// reported so an operator can pinpoint the tampered row.
final class AuditChainStatus {
  /// The chain verified without gaps.
  const AuditChainStatus.valid(this.checkedEntries)
    : isIntact = true,
      firstBrokenSeq = null,
      reason = null;

  /// The chain is broken at [firstBrokenSeq].
  const AuditChainStatus.broken({
    required this.checkedEntries,
    required this.firstBrokenSeq,
    required this.reason,
  }) : isIntact = false;

  /// Whether every link (and every checkpoint) matched.
  final bool isIntact;

  /// How many entries were verified before stopping.
  final int checkedEntries;

  /// Sequence number of the first entry that failed, when [isIntact] is false.
  final int? firstBrokenSeq;

  /// Human-readable cause of the break, when [isIntact] is false.
  final String? reason;
}
