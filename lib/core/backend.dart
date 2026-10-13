import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'demo/demo_store.dart';
import 'env.dart';

part 'backend.g.dart';

/// Which backend the data layer talks to. Repository providers switch on this,
/// so presentation and domain code never know which one is active.
enum Backend { supabase, demo }

@Riverpod(keepAlive: true)
Backend backend(Ref ref) => Env.demo ? Backend.demo : Backend.supabase;

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@Riverpod(keepAlive: true)
DemoStore demoStore(Ref ref) => DemoStore.seeded();
