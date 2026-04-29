// aq_tool_registry/lib/src/tool_registry_client.dart

import 'package:aq_schema/data_layer.dart';
import 'package:aq_schema/tools.dart';

/// Tool Registry client.
final class ToolRegistryClient implements IAQToolRegistrySimple {
  final Map<String, List<ToolRecord>> _records = {};

  @override
  Future<void> register(ToolRecord record) async {
    final key = record.id;
    _records.putIfAbsent(key, () => []).add(record);
  }

  @override
  Future<ToolContract> resolve(ToolRef ref) async {
    final key = ref.namespace != null ? '${ref.namespace}/${ref.name}' : ref.name;
    final records = _records[key];

    if (records == null || records.isEmpty) {
      throw ToolNotFoundException(ref);
    }

    final record = ref.exactVersion != null
        ? _findVersion(records, ref.exactVersion!)
        : records.last; // Latest

    return record.contract;
  }

  @override
  Future<List<ToolRecord>> list({String? namespace}) async {
    final all = _records.values.expand((list) => list).toList();
    if (namespace == null) return all;
    return all.where((r) => r.id.startsWith('$namespace/')).toList();
  }

  ToolRecord _findVersion(List<ToolRecord> records, Semver version) {
    final match = records.where((r) => r.version == version).firstOrNull;
    if (match == null) {
      throw ToolVersionNotFoundException(records.first.id, version);
    }
    return match;
  }
}

final class ToolNotFoundException implements Exception {
  final ToolRef ref;
  ToolNotFoundException(this.ref);
  @override
  String toString() => 'Tool not found: ${ref.fullId}';
}

final class ToolVersionNotFoundException implements Exception {
  final String id;
  final Semver version;
  ToolVersionNotFoundException(this.id, this.version);
  @override
  String toString() => 'Tool version not found: $id@$version';
}
