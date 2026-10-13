import 'dart:async';

import '../../features/applications/domain/application.dart';
import '../../features/attention/domain/attention_item.dart';
import '../time/deadline.dart';

/// In-memory data for demo mode (no Supabase configured). Dates are generated
/// relative to "now" so the Today screen always has something realistic.
class DemoStore {
  DemoStore._(this.applications, this.attention);

  final List<Application> applications;
  final List<AttentionItem> attention;

  final _signedIn = StreamController<bool>.broadcast();
  bool signedIn = false;
  Stream<bool> get signedInChanges => _signedIn.stream;
  void setSignedIn(bool value) {
    signedIn = value;
    _signedIn.add(value);
  }

  /// Simulated network latency so loading states are visible in demo mode.
  static const latency = Duration(milliseconds: 450);

  factory DemoStore.seeded({DateTime? now}) {
    final n = now ?? DateTime.now();
    Deadline d(String zone, int daysFromNow) {
      final day = n.add(Duration(days: daysFromNow));
      return Deadline.wallClock(zone, day.year, day.month, day.day);
    }

    final apps = <Application>[
      Application(
        id: 'a1',
        institutionName: 'University of Toronto',
        programmeName: 'Computer Science',
        degreeType: 'phd',
        department: 'Department of Computer Science',
        researchArea: 'Machine learning systems',
        country: 'CA',
        stage: ApplicationStage.preparing,
        priority: 1,
        deadline: d('America/Toronto', 3),
        fundingDeadline: d('America/Toronto', 10),
        requirementsDone: 4,
        requirementsTotal: 7,
        lettersSubmitted: 1,
        lettersTotal: 3,
        programmeUrl: 'https://web.cs.toronto.edu/graduate',
      ),
      Application(
        id: 'a2',
        institutionName: 'ETH Zürich',
        programmeName: 'Data Science',
        degreeType: 'msc',
        researchArea: 'Statistical learning',
        country: 'CH',
        stage: ApplicationStage.ready,
        priority: 2,
        deadline: d('Europe/Zurich', 9),
        requirementsDone: 6,
        requirementsTotal: 6,
        lettersSubmitted: 2,
        lettersTotal: 2,
      ),
      Application(
        id: 'a3',
        institutionName: 'University of Edinburgh',
        programmeName: 'Informatics',
        degreeType: 'phd',
        researchArea: 'Natural language processing',
        country: 'GB',
        stage: ApplicationStage.shortlisted,
        priority: 1,
        deadline: d('Europe/London', 24),
        requirementsDone: 1,
        requirementsTotal: 6,
        lettersTotal: 3,
      ),
      Application(
        id: 'a4',
        institutionName: 'KAUST',
        programmeName: 'Computer Science',
        degreeType: 'phd',
        country: 'SA',
        stage: ApplicationStage.researching,
        priority: 3,
        deadline: d('Asia/Riyadh', 41),
      ),
      Application(
        id: 'a5',
        institutionName: 'University of British Columbia',
        programmeName: 'Computer Science',
        degreeType: 'msc',
        country: 'CA',
        stage: ApplicationStage.submitted,
        priority: 2,
        deadline: d('America/Vancouver', -5),
        requirementsDone: 6,
        requirementsTotal: 6,
        lettersSubmitted: 3,
        lettersTotal: 3,
      ),
      Application(
        id: 'a6',
        institutionName: 'Technical University of Munich',
        programmeName: 'Informatics',
        degreeType: 'msc',
        country: 'DE',
        stage: ApplicationStage.underReview,
        priority: 2,
        deadline: d('Europe/Berlin', -30),
        requirementsDone: 5,
        requirementsTotal: 5,
      ),
    ];

    final feed = <AttentionItem>[
      AttentionItem(
        type: AttentionType.requirement,
        itemId: 'r1',
        applicationId: 'a1',
        title: 'Official transcript',
        context: 'University of Toronto · PhD Computer Science',
        reason: 'Depends on someone else — chase early',
        dueAt: n.subtract(const Duration(days: 1)),
        score: 115,
      ),
      AttentionItem(
        type: AttentionType.followUp,
        itemId: 'm1',
        professorId: 'p1',
        title: 'Follow up with Prof. Amara Okafor',
        context: 'University of Edinburgh',
        reason: 'No reply since ${n.subtract(const Duration(days: 8)).day} ${_month(n.subtract(const Duration(days: 8)))}',
        dueAt: n.subtract(const Duration(hours: 2)),
        score: 105,
      ),
      AttentionItem(
        type: AttentionType.applicationDeadline,
        itemId: 'a1',
        applicationId: 'a1',
        title: 'Application deadline',
        context: 'University of Toronto · PhD Computer Science',
        reason: '3 requirement(s), 2 letter(s) outstanding',
        dueAt: apps[0].deadline!.instant,
        dueZone: 'America/Toronto',
        score: 105,
      ),
      AttentionItem(
        type: AttentionType.task,
        itemId: 't1',
        title: 'Book IELTS test date',
        reason: 'High priority task',
        dueAt: n.add(const Duration(hours: 20)),
        score: 100,
      ),
      AttentionItem(
        type: AttentionType.letter,
        itemId: 'l1',
        applicationId: 'a1',
        title: 'Letter from Dr. Bello',
        context: 'University of Toronto · PhD Computer Science',
        reason: 'Invited — not submitted yet',
        dueAt: apps[0].deadline!.instant,
        dueZone: 'America/Toronto',
        score: 85,
      ),
      AttentionItem(
        type: AttentionType.requirement,
        itemId: 'r2',
        applicationId: 'a1',
        title: 'Statement of purpose',
        context: 'University of Toronto · PhD Computer Science',
        reason: 'In progress',
        dueAt: apps[0].deadline!.instant,
        dueZone: 'America/Toronto',
        score: 80,
      ),
      AttentionItem(
        type: AttentionType.applicationDeadline,
        itemId: 'a2',
        applicationId: 'a2',
        title: 'Application deadline',
        context: 'ETH Zürich · MSc Data Science',
        reason: 'Everything ticked off — submit it',
        dueAt: apps[1].deadline!.instant,
        dueZone: 'Europe/Zurich',
        score: 45,
      ),
      AttentionItem(
        type: AttentionType.fundingDeadline,
        itemId: 'a1-f',
        applicationId: 'a1',
        title: 'Funding deadline',
        context: 'University of Toronto · PhD Computer Science',
        reason: 'Scholarship / funding application',
        dueAt: apps[0].fundingDeadline!.instant,
        dueZone: 'America/Toronto',
        score: 40,
      ),
    ];

    return DemoStore._(apps, feed);
  }

  static String _month(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}
