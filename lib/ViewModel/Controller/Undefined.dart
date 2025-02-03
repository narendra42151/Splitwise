class UnifiedItem {
  final DateTime createdAt;
  final dynamic item; // Can be either ExpenseModel or MessageGet

  UnifiedItem({required this.createdAt, required this.item});
}
