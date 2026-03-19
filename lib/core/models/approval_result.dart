/// Result of a role-based approval flow (F-005/F-009).
/// Returned by [showRoleBasedApproval] and consumed by void/discount handlers.
class ApprovalResult {
  /// The ID of the manager/owner who approved the action.
  /// For owners, this is their own ID (self-approval).
  final String approverId;

  /// Whether the PIN was verified (true) or bypassed (owner).
  final bool pinVerified;

  const ApprovalResult({
    required this.approverId,
    this.pinVerified = true,
  });
}
