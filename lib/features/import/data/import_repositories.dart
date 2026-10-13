import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../../applications/data/demo_applications_repository.dart';
import '../../applications/data/supabase_applications_repository.dart';
import '../../applications/domain/application_draft.dart';
import '../domain/import_repository.dart';

part 'import_repositories.g.dart';

@Riverpod(keepAlive: true)
ImportRepository importRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseImportRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoImportRepository(ref.watch(demoStoreProvider)),
    };

/// One RPC = one transaction (see migration 20261014000004_import.sql).
class SupabaseImportRepository implements ImportRepository {
  SupabaseImportRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ImportSummary> importAll(List<ApplicationDraft> drafts, {bool seedRequirements = false}) async {
    final rows = [
      for (final d in drafts)
        {
          'institution_name': d.institutionName.trim(),
          'country': blankToNull(d.institutionCountry)?.toUpperCase(),
          ...applicationColumns(d),
        },
    ];
    final result = await _client.rpc<List<dynamic>>(
      'import_applications',
      params: {'p_rows': rows, 'p_seed_requirements': seedRequirements},
    );
    final r = result.single as Map<String, dynamic>;
    return ImportSummary(
      applications: r['created_applications'] as int,
      institutions: r['created_institutions'] as int,
    );
  }
}

class DemoImportRepository implements ImportRepository {
  DemoImportRepository(this._store);

  final DemoStore _store;

  @override
  Future<ImportSummary> importAll(List<ApplicationDraft> drafts, {bool seedRequirements = false}) async {
    final repo = DemoApplicationsRepository(_store);
    final before = _store.institutions.length;
    for (final d in drafts) {
      final id = await repo.create(d);
      if (seedRequirements) {
        final i = _store.applications.indexWhere((a) => a.id == id);
        _store.applications[i] = _store.applications[i].copyWith(requirementsTotal: 5);
      }
    }
    return ImportSummary(applications: drafts.length, institutions: _store.institutions.length - before);
  }
}
