import 'package:flutter/foundation.dart';

@immutable
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}
