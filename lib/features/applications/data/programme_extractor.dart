import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/programme_extraction.dart';

part 'programme_extractor.g.dart';

@Riverpod(keepAlive: true)
ProgrammeExtractor programmeExtractor(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseProgrammeExtractor(ref.watch(supabaseClientProvider)),
      Backend.demo => const DemoProgrammeExtractor(),
    };

/// Calls the extract-programme Edge Function.
class SupabaseProgrammeExtractor implements ProgrammeExtractor {
  SupabaseProgrammeExtractor(this._client);

  final SupabaseClient _client;

  @override
  Future<ProgrammeExtraction> extract({String? url, String? text}) async {
    try {
      final res = await _client.functions.invoke('extract-programme', body: {
        if (url != null && url.trim().isNotEmpty) 'url': url.trim(),
        if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      });
      return ProgrammeExtraction.fromJson((res.data as Map).cast<String, dynamic>());
    } on FunctionsFetchException {
      throw const ExtractionException('Couldn’t reach gradll. Check your connection and try again.');
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] is String) {
        throw ExtractionException(details['error'] as String, code: details['code'] as String?);
      }
      throw const ExtractionException('The page reader had a problem. Try again shortly.');
    }
  }
}

/// Demo mode has no backend: returns a fixed, realistic result so the flow
/// can be tried end to end.
class DemoProgrammeExtractor implements ProgrammeExtractor {
  const DemoProgrammeExtractor();

  @override
  Future<ProgrammeExtraction> extract({String? url, String? text}) async {
    await Future<void>.delayed(DemoStore.latency * 3);
    if ((url ?? '').trim().isEmpty && (text ?? '').trim().length < 200) {
      throw const ExtractionException('That’s too little text to work with. Copy the whole page.');
    }
    final year = DateTime.now().year + 1;
    return ProgrammeExtraction.fromJson({
      'is_programme_page': true,
      'institution_name': 'University of Cape Town',
      'country_code': 'ZA',
      'location': 'Cape Town, Western Cape',
      'programme_name': 'Data Science',
      'degree': 'msc',
      'department': 'Department of Statistical Sciences',
      'research_area': null,
      'deadline_date': '$year-01-31',
      'deadline_time': null,
      'deadline_timezone': null,
      'deadline_month_only': false,
      'funding_deadline_date': null,
      'opens_on': '${year - 1}-${DateTime.now().month.toString().padLeft(2, '0')}-01',
      'opens_month_only': true,
      'decision_expected': null,
      'fee_amount': 300,
      'fee_currency': 'ZAR',
      'fee_waiver_available': false,
      'tuition_amount': 95000,
      'tuition_currency': 'ZAR',
      'portal_url': 'https://applyonline.uct.ac.za',
      'requires_professor_acceptance': false,
      'requirements': ['Academic transcripts', 'CV', 'Motivation letter', '2 recommendation letters'],
      'notes': 'Demo result: in demo mode every link returns this sample programme.',
      'check_fields': ['tuition_amount'],
      'source_url': (url ?? '').trim().isEmpty ? null : url!.trim(),
      'truncated': false,
      'cached': false,
    });
  }
}
