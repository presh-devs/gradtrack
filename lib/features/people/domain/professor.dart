import 'package:freezed_annotation/freezed_annotation.dart';

part 'professor.freezed.dart';

/// What the professor has said about taking students.
enum ProfessorStance {
  unknown('unknown', 'No answer yet'),
  interested('interested', 'Interested'),
  notTakingStudents('not_taking_students', 'Not taking students'),
  declined('declined', 'Declined');

  const ProfessorStance(this.db, this.label);
  final String db;
  final String label;

  static ProfessorStance fromDb(String? value) => values.firstWhere((s) => s.db == value, orElse: () => unknown);
}

/// Where the conversation stands (`professor_outreach_status.thread_state`).
enum OutreachState {
  toContact('to_contact', 'To contact'),
  drafting('drafting', 'Drafting'),
  awaitingReply('awaiting_reply', 'Awaiting reply'),
  replied('replied', 'Replied'),
  closed('closed', 'Closed');

  const OutreachState(this.db, this.label);
  final String db;
  final String label;

  static OutreachState fromDb(String? value) => values.firstWhere((s) => s.db == value, orElse: () => toContact);
}

@freezed
abstract class Professor with _$Professor {
  const Professor._();

  const factory Professor({
    required String id,
    required String institutionId,
    required String institutionName,
    required String name,
    String? academicTitle,
    String? department,
    String? email,
    String? profileUrl,
    String? researchInterests,
    String? notes,
    @Default(ProfessorStance.unknown) ProfessorStance stance,
    @Default(OutreachState.toContact) OutreachState state,
    DateTime? lastSentAt,
    DateTime? lastReplyAt,

    /// When to follow up if there's no reply (null = no reminder).
    DateTime? followUpAt,

    /// Applications this professor is relevant to (`application_professors`).
    @Default(<String>[]) List<String> applicationIds,
  }) = _Professor;

  /// "Prof. Wang Qingsong"
  String get displayName => academicTitle == null ? name : '$academicTitle $name';

  bool followUpDue([DateTime? now]) =>
      state == OutreachState.awaitingReply && followUpAt != null && !followUpAt!.isAfter(now ?? DateTime.now());
}

/// Everything the add/edit dialog edits.
@freezed
abstract class ProfessorDraft with _$ProfessorDraft {
  const ProfessorDraft._();

  const factory ProfessorDraft({
    /// Existing institution, or null to create one named [institutionName].
    String? institutionId,
    @Default('') String institutionName,
    @Default('') String name,
    String? academicTitle,
    String? department,
    String? email,
    String? profileUrl,
    String? researchInterests,
    String? notes,
  }) = _ProfessorDraft;

  factory ProfessorDraft.fromProfessor(Professor p) => ProfessorDraft(
        institutionId: p.institutionId,
        institutionName: p.institutionName,
        name: p.name,
        academicTitle: p.academicTitle,
        department: p.department,
        email: p.email,
        profileUrl: p.profileUrl,
        researchInterests: p.researchInterests,
        notes: p.notes,
      );

  /// Empty = valid. Keys: institution, name, email, profileUrl.
  Map<String, String> validate() => {
        if (institutionName.trim().isEmpty) 'institution': 'Choose or add a university',
        if (name.trim().isEmpty) 'name': 'Enter the professor’s name',
        if ((email?.trim() ?? '').isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email!.trim()))
          'email': 'Enter a valid email address',
        if ((profileUrl?.trim() ?? '').isNotEmpty && !RegExp(r'^https?://\S+\.\S+').hasMatch(profileUrl!.trim()))
          'profileUrl': 'Enter a full link starting with https://',
      };
}

/// One professor ready to import (see professor_import.dart).
class ProfessorImport {
  const ProfessorImport({
    required this.draft,
    this.contacted = false,
  });

  final ProfessorDraft draft;

  /// The sheet says they were already emailed ("sent").
  final bool contacted;
}
