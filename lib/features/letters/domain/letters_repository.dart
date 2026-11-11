import 'letters.dart';

abstract interface class LettersRepository {
  /// Recommenders by name, with how many letters each is writing.
  Future<List<Recommender>> recommenders();

  Future<String> createRecommender(RecommenderDraft draft);

  Future<void> updateRecommender(String id, RecommenderDraft draft);

  /// Also removes their letter requests.
  Future<void> deleteRecommender(String id);

  Future<List<LetterRequest>> forApplication(String applicationId);

  /// Adds [recommenderId] to the application (status "not asked yet").
  Future<LetterRequest> addLetter(String applicationId, String recommenderId);

  /// Sets the status and stamps when it happened.
  Future<void> setStatus(String letterId, LetterStatus status);

  Future<void> removeLetter(String letterId);
}
