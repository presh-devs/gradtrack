import '../../../core/demo/demo_store.dart';
import '../domain/application.dart';
import '../domain/application_draft.dart';
import '../domain/applications_repository.dart';
import '../domain/institution.dart';

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
  Future<String> create(ApplicationDraft draft) async {
    await Future<void>.delayed(DemoStore.latency);
    final institution = _resolveInstitution(draft);
    final id = 'a${_store.nextId()}';
    _store.applications.add(_apply(draft, institution, Application(
      id: id,
      institutionId: institution.id,
      institutionName: institution.name,
      programmeName: '',
      degree: draft.degree,
      stage: draft.stage,
    )));
    return id;
  }

  @override
  Future<void> update(String id, ApplicationDraft draft) async {
    await Future<void>.delayed(DemoStore.latency);
    final i = _store.applications.indexWhere((a) => a.id == id);
    if (i < 0) throw StateError('Application not found');
    _store.applications[i] = _apply(draft, _resolveInstitution(draft), _store.applications[i]);
  }

  @override
  Future<void> updateStage(String id, ApplicationStage stage) async {
    await Future<void>.delayed(DemoStore.latency);
    final i = _store.applications.indexWhere((a) => a.id == id);
    _store.applications[i] = _store.applications[i].copyWith(stage: stage);
  }

  Institution _resolveInstitution(ApplicationDraft d) {
    final existing = _store.institutions.where(
      (i) => i.id == d.institutionId || i.name.toLowerCase() == d.institutionName.trim().toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;
    final created = Institution(
      id: 'i${_store.nextId()}',
      name: d.institutionName.trim(),
      country: blankToNull(d.institutionCountry)?.toUpperCase(),
      defaultTz: d.deadline.zone,
    );
    _store.institutions.add(created);
    return created;
  }

  static Application _apply(ApplicationDraft d, Institution inst, Application base) {
    final fee = d.parsedFee;
    return base.copyWith(
      institutionId: inst.id,
      institutionName: inst.name,
      country: inst.country,
      programmeName: d.programmeName.trim(),
      degree: d.degree,
      stage: d.stage,
      outcome: d.stage == ApplicationStage.decided ? base.outcome : null,
      priority: d.priority,
      deadline: d.deadline.toDeadline(),
      fundingDeadline: d.fundingDeadline.toDeadline(),
      department: blankToNull(d.department),
      researchArea: blankToNull(d.researchArea),
      programmeUrl: blankToNull(d.programmeUrl),
      portalUrl: blankToNull(d.portalUrl),
      portalUsername: blankToNull(d.portalUsername),
      fundingUrl: blankToNull(d.fundingUrl),
      feeAmount: fee,
      feeCurrency: fee == null ? null : d.feeCurrency?.trim().toUpperCase(),
      feeWaiver: d.feeWaiver,
      notes: blankToNull(d.notes),
    );
  }
}

class DemoInstitutionsRepository implements InstitutionsRepository {
  DemoInstitutionsRepository(this._store);

  final DemoStore _store;

  @override
  Future<List<Institution>> list() async {
    await Future<void>.delayed(DemoStore.latency);
    return [..._store.institutions]..sort((a, b) => a.name.compareTo(b.name));
  }
}
