import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  print('🚀 Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter binding initialized');

  try {
    print('🔄 Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://spydethnbkkiuoyirnas.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNweWRldGhuYmtraXVveWlybmFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3OTc0NTMsImV4cCI6MjA3MjM3MzQ1M30.dmNp_hvsdWW2hW4MFggZOsF6zOn8wyNKaNhPIT71j7M',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  // Initialize notification service in background (non-blocking)
  print('🔄 Starting notification service initialization...');
  NotificationService().initializeAsync().then((_) {
    print('✅ Notification service initialized successfully');
  }).catchError((e) {
    print('❌ Notification service initialization failed: $e');
  });

  print('🎯 Starting app...');
  runApp(MyApp());
}


