import '../../../core/theme/tokens.dart';
import '../domain/application.dart';

/// Presentation-only mapping of stages to colour tones (kept out of the
/// domain layer, which must not depend on Flutter).
extension StageStyle on ApplicationStage {
  GtTone tone(GtPalette gt) => switch (this) {
        ApplicationStage.researching => gt.neutral,
        ApplicationStage.shortlisted => gt.violet,
        ApplicationStage.preparing => gt.warning,
        ApplicationStage.ready => gt.info,
        ApplicationStage.submitted ||
        ApplicationStage.underReview ||
        ApplicationStage.interview =>
          gt.success,
        ApplicationStage.decided => gt.violet,
      };
}

extension DueTone on DateTime {
  /// Red when overdue or < 3 days, amber within a week, calm otherwise.
  GtTone dueTone(GtPalette gt) {
    final left = difference(DateTime.now());
    if (left.inHours < 72) return gt.danger;
    if (left.inDays < 7) return gt.warning;
    return gt.neutral;
  }
}
