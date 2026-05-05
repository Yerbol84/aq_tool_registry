// aq_tool_registry/lib/src/in_memory_tool_repository.dart
//
// In-memory реализация IToolRepository.
// TECH_DEBT(TD-01): заменить на VaultToolRepository после подключения dart_vault.

import 'package:aq_schema/tools.dart';

final class InMemoryToolRepository implements IToolRepository {
  // id → список версий (последняя = актуальная)
  final Map<String, List<ToolRecord>> _store = {};

  @override
  Future<void> save(ToolRecord record) async {
    final versions = _store.putIfAbsent(record.id, () => []);
    final idx = versions.indexWhere((r) => r.version == record.version);
    if (idx >= 0) {
      versions[idx] = record;
    } else {
      versions.add(record);
    }
  }

  @override
  Future<ToolRecord?> findById(String id) async =>
      _store[id]?.lastOrNull;

  @override
  Future<List<ToolRecord>> findVersions(String id) async =>
      List.unmodifiable(_store[id] ?? const []);

  @override
  Future<List<ToolRecord>> findAll({String? namespace}) async {
    final all = _store.values.expand((v) => v).toList();
    if (namespace == null) return all;
    return all.where((r) => r.id.startsWith('$namespace/')).toList();
  }

  @override
  Future<void> delete(String id) async => _store.remove(id);
}
