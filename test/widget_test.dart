import 'package:ayucare/configuration/app_config.dart';
import 'package:ayucare/data/content_repository.dart';
import 'package:ayucare/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentRepository repo;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repo = ContentRepository();
    await repo.load();
  });

  testWidgets('home shows brand, search, A-Z and safety notice',
      (tester) async {
    await tester.pumpWidget(AyuCareApp(repo: repo));
    await tester.pumpAndSettle();
    expect(find.text('AyuCare'), findsWidgets);
    expect(find.text('Search conditions, symptoms or herbs…'), findsOneWidget);
    expect(find.text('AyuCare Safety Notice'), findsOneWidget);
    expect(find.text('Read Full Disclaimer'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });

  test('all commercial flags are OFF for MVP', () {
    expect(FeatureFlags.adsEnabled, isFalse);
    expect(FeatureFlags.affiliateEnabled, isFalse);
    expect(FeatureFlags.remoteContentEnabled, isFalse);
    expect(FeatureFlags.analyticsEnabled, isFalse);
  });
}
