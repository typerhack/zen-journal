import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen_journal/app.dart';
import 'package:zen_journal/features/journal/ui/journal_page.dart';

void main() {
  testWidgets('First launch opens onboarding welcome', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: ZenJournalApp()));
    await tester.pump();

    expect(find.text('zen journal'), findsAtLeastNWidgets(1));
    expect(find.text('begin'), findsOneWidget);
  });

  testWidgets('Completed onboarding opens journal', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding.is_complete': true,
    });
    await tester.pumpWidget(const ProviderScope(child: ZenJournalApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ZenJournalApp), findsOneWidget);
    expect(find.byType(JournalPage), findsOneWidget);
  });
}
