import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://spydethnbkkiuoyirnas.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNweWRldGhuYmtraXVveWlybmFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3OTc0NTMsImV4cCI6MjA3MjM3MzQ1M30.dmNp_hvsdWW2hW4MFggZOsF6zOn8wyNKaNhPIT71j7M',
  );

  runApp(MyApp());
}


