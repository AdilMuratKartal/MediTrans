import 'package:flutter_test/flutter_test.dart';
import 'package:meditrans/main.dart';

void main() {
  testWidgets(
    'MediTrans renders Home, Meditation Portal, Profile, and interactive modals without mascot',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MediTransApp());
      await tester.pumpAndSettle();

      // 1. HomeMoodScreen check
      expect(find.text('Aura Mind'), findsOneWidget);
      expect(find.text('İçsel Frekansını Kaydet'), findsOneWidget);
      expect(find.text('Duygu Ekle'), findsOneWidget);

      // Open 'Duygu Ekle' modal bottom sheet and pick 'Umutlu'
      await tester.tap(find.text('Duygu Ekle'));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Duygu Ekle'), findsOneWidget);
      await tester.tap(find.text('Umutlu').last);
      await tester.pumpAndSettle();
      expect(find.text('Umutlu'), findsOneWidget);

      // 2. Switch to Meditasyon Tab
      await tester.tap(find.text('Meditasyon').last);
      await tester.pumpAndSettle();
      expect(find.text('Derin Huzur Alanı'), findsOneWidget);
      expect(find.text('Nefes\nEgzersizleri'), findsOneWidget);
      expect(find.text('Hz\nFrekansları'), findsOneWidget);

      // 3. Switch to Profil Tab
      await tester.tap(find.text('Profil').last);
      await tester.pumpAndSettle();
      expect(find.text('Profil & Analiz'), findsOneWidget);
      expect(find.text('Adil Murat'), findsOneWidget);
      expect(find.text('Duygu Grafiği'), findsOneWidget);
      expect(find.text('Profili Düzenle'), findsOneWidget);

      // Open 'Profili Düzenle' sheet and save
      await tester.tap(find.text('Profili Düzenle'));
      await tester.pumpAndSettle();
      expect(find.text('Değişiklikleri Kaydet'), findsOneWidget);
      await tester.tap(find.text('Değişiklikleri Kaydet'));
      await tester.pumpAndSettle();
    },
  );
}
