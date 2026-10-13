import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend.dart';
import '../domain/applications_repository.dart';
import '../domain/institution.dart';
import 'demo_applications_repository.dart';
import 'supabase_applications_repository.dart';

part 'applications_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ApplicationsRepository applicationsRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseApplicationsRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoApplicationsRepository(ref.watch(demoStoreProvider)),
    };

@Riverpod(keepAlive: true)
InstitutionsRepository institutionsRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseInstitutionsRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoInstitutionsRepository(ref.watch(demoStoreProvider)),
    };
