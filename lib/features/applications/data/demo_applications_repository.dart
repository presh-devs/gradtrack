import '../../../core/demo/demo_store.dart';
import '../domain/application.dart';
import '../domain/applications_repository.dart';

class DemoApplicationsRepository implements ApplicationsRepository {
  DemoApplicationsRepository(this._store);

  final DemoStore _store;

  @override
  Future<List<Application>> list() async {
    await Future<void>.delayed(DemoStore.latency);
    final apps = [..._store.applications]..sort((a, b) {
        final ad = a.deadline?.instant, bd = b.deadline?.instant;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
    return apps;
  }

  @override
  Future<void> updateStage(String id, ApplicationStage stage) async {
    await Future<void>.delayed(DemoStore.latency);
    final i = _store.applications.indexWhere((a) => a.id == id);
    _store.applications[i] = _store.applications[i].copyWith(stage: stage);
  }
}
