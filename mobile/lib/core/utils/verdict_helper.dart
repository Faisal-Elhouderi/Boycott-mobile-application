String resolveVerdict(String verdict, String label) {
  if (verdict.trim().isNotEmpty) {
    return verdict.trim();
  }
  final normalized = label.trim().toLowerCase();
  if (normalized.contains('مقاطعة') ||
      normalized.contains('تجنب') ||
      normalized.contains('محظور')) {
    return 'AVOID';
  }
  if (normalized.contains('تحذير') || normalized.contains('حذر')) {
    return 'CAUTION';
  }
  if (normalized.contains('بديل') ||
      normalized.contains('مفضل') ||
      normalized.contains('موصى')) {
    return 'PREFERRED';
  }
  return 'UNKNOWN';
}
