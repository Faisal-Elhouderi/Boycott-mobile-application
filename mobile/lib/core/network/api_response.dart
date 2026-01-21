Map<String, dynamic> unwrapSuccessMap(dynamic payload) {
  final data = unwrapSuccess(payload);
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return <String, dynamic>{};
}

List<dynamic> unwrapSuccessList(dynamic payload) {
  final data = unwrapSuccess(payload);
  if (data is List) {
    return data;
  }
  if (data is Map) {
    final candidates = [
      data['items'],
      data['results'],
      data['list'],
      data['data'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
  }
  return const [];
}

dynamic unwrapSuccess(dynamic payload) {
  if (payload is Map && payload['success'] is Map) {
    final success = payload['success'] as Map;
    if (success['data'] != null) {
      return success['data'];
    }
    return success;
  }
  if (payload is Map && payload['data'] != null) {
    return payload['data'];
  }
  return payload;
}
