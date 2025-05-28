// Utility for safe map extraction

typedef DynamicMap = Map<String, dynamic>;

T? getMapValue<T>(dynamic map, String key) {
  if (map is DynamicMap && map[key] is T) return map[key] as T;
  if (map is DynamicMap && map[key] != null) {
    try {
      return map[key].toString() as T;
    } catch (_) {}
  }
  return null;
}

// Usage: getMapValue<String>(service, 'name')
