// aq_tool_registry/lib/src/tool_registry_client.dart

import 'package:aq_schema/data_layer.dart';
import 'package:aq_schema/tools.dart';

/// Tool Registry client.
final class ToolRegistryClient implements IAQToolRegistrySimple {
  IToolRepository get _repo => IToolRepository.instance;

  @override
  Future<void> register(ToolRecord record) => _repo.save(record);

  @override
  Future<ToolContract> resolve(ToolRef ref) async {
    final key = ref.namespace != null ? '${ref.namespace}/${ref.name}' : ref.name;

    if (ref.exactVersion != null) {
      final versions = await _repo.findVersions(key);
      final match = versions.where((r) => r.version == ref.exactVersion).firstOrNull;
      if (match == null) throw ToolVersionNotFoundException(key, ref.exactVersion!);
      return match.contract;
    }

    final record = await _repo.findById(key);
    if (record == null) throw ToolNotFoundException(ref);
    return record.contract;
  }

  @override
  Future<List<ToolRecord>> list({String? namespace}) =>
      _repo.findAll(namespace: namespace);
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
