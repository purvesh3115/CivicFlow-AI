import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen_connect/providers/ai_assistant_provider.dart';
import 'package:citizen_connect/providers/auth_provider.dart';
import 'package:citizen_connect/providers/complaint_provider.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_assistant_home_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_chat_triage_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_image_analysis_screen.dart';
import 'package:citizen_connect/screens/citizen/ai/ai_voice_assistant_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiAssistantProvider Unit Tests', () {
    test('Initialization has welcome message and suggestions', () {
      final provider = AiAssistantProvider();
      expect(provider.messages.isNotEmpty, true);
      expect(provider.messages.first.isAssistant, true);
      expect(provider.messages.first.text.contains('Civic Assistant') ||
          provider.messages.first.text.contains('help you today'), true);
      expect(provider.suggestions.length, 5);
      expect(provider.suggestions.contains('How do I report a pothole?'), true);
    });

    test('Pothole inquiry generates structured road triage card', () async {
      final provider = AiAssistantProvider();
      await provider.sendMessage('There is a dangerous pothole on 4th street');

      expect(provider.messages.length >= 2, true);
      final reply = provider.messages.last;
      expect(reply.isAssistant, true);
      expect(reply.insightCard != null, true);
      expect(reply.insightCard!.title, 'Pothole');
      expect(reply.insightCard!.category, 'Roads');
      expect(reply.insightCard!.department, 'Roads & Public Works');
      expect(reply.insightCard!.matchScore, 94);
    });

    test('Garbage inquiry generates sanitation triage card', () async {
      final provider = AiAssistantProvider();
      await provider.sendMessage('Garbage is overflowing everywhere');

      final reply = provider.messages.last;
      expect(reply.insightCard != null, true);
      expect(reply.insightCard!.category, 'Garbage');
      expect(reply.insightCard!.department, 'Solid Waste Management');
      expect(reply.insightCard!.matchScore, 96);
    });

    test('Complaint tracking inquiry generates tracking card with timeline', () async {
      final provider = AiAssistantProvider();
      await provider.sendMessage('Where is my complaint status?');

      final reply = provider.messages.last;
      expect(reply.insightCard != null, true);
      expect(reply.insightCard!.isTrackingCard, true);
      expect(reply.insightCard!.complaintId, '#CC-2026-00125');
      expect(reply.insightCard!.status, 'In Progress');
      expect(reply.insightCard!.timelineSteps?.length, 5);
    });

    test('Image analysis simulation returns confidence score and severity', () {
      final provider = AiAssistantProvider();
      final result = provider.runImageAnalysis();

      expect(result.issueName, 'Pothole');
      expect(result.category, 'Road Infrastructure');
      expect(result.confidenceScore, 94);
      expect(result.severity, 'High');
      expect(result.location, '124 Main St, Cityville');
      expect(provider.currentImageAnalysis, result);
    });

    test('Voice assistant toggle and transcript update', () {
      final provider = AiAssistantProvider();
      expect(provider.isVoiceListening, false);

      provider.toggleVoiceListening();
      expect(provider.isVoiceListening, true);

      provider.setVoiceTranscript('Water pipe is broken');
      expect(provider.voiceTranscript, 'Water pipe is broken');
    });
  });

  group('Phase 6 UI Screen Widget Tests', () {
    testWidgets('AiAssistantHomeScreen renders header, bento cards, and suggestion chips',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AiAssistantHomeScreen(),
          ),
        ),
      );

      expect(find.text('CitizenConnect AI'), findsOneWidget);
      expect(find.textContaining("Hi! I'm your Civic Assistant"), findsOneWidget);
      expect(find.text('Suggested Questions'), findsOneWidget);
      expect(find.text('How do I report a pothole?'), findsOneWidget);
      expect(find.text('How can I help?'), findsOneWidget);
      expect(find.text('Report an Issue'), findsOneWidget);
      expect(find.text('Track My Complaint'), findsOneWidget);
      expect(find.text('Analyze an Image'), findsOneWidget);
      expect(find.text('Government Services'), findsOneWidget);
      expect(find.text('AI Enhanced'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    });

    testWidgets('AiChatTriageScreen renders online status, chips, and sends message',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AiChatTriageScreen(),
          ),
        ),
      );

      expect(find.text('CitizenConnect AI'), findsOneWidget);
      expect(find.text('AI Civic Assistant Online'), findsOneWidget);
      expect(find.text('Report a pothole'), findsOneWidget);
      expect(find.text('Overflowing garbage'), findsOneWidget);

      // Tap on preset suggestion
      await tester.tap(find.text('Report a pothole'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('large pothole near my college'), findsOneWidget);
      expect(find.text('RECOMMENDED FOR YOU'), findsOneWidget);
      expect(find.text('94% Match'), findsOneWidget);
      expect(find.text('CREATE COMPLAINT'), findsOneWidget);
    });

    testWidgets('AiImageAnalysisScreen renders laser scan preview and assessment table',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AiImageAnalysisScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('AI Image Analysis'), findsOneWidget);
      expect(find.text('AI DETECTED'), findsOneWidget);
      expect(find.text('Pothole'), findsOneWidget);
      expect(find.text('94% Confidence'), findsOneWidget);
      expect(find.text('Road Infrastructure'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Roads & Public Works'), findsOneWidget);
      expect(find.text('CREATE COMPLAINT'), findsOneWidget);
      expect(find.text('ANALYZE AGAIN'), findsOneWidget);
      expect(find.textContaining('CitizenConnect Vision AI v2.4'), findsOneWidget);
    });

    testWidgets('AiVoiceAssistantScreen renders 7-bar waveform, transcript, and mic controls',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AiVoiceAssistantScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CitizenConnect AI'), findsOneWidget);
      expect(find.text('Listening...'), findsOneWidget);
      expect(find.text('You said:'), findsOneWidget);
      expect(find.text('"There is garbage near my house."'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.text('EDIT'), findsOneWidget);
      expect(find.text('CONFIRM'), findsOneWidget);

      // Tap microphone to pause
      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Paused'), findsOneWidget);
    });
  });
}
