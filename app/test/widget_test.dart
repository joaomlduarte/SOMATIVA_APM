import 'package:flutter_test/flutter_test.dart';

import 'package:mange_flix/main.dart';

void main() {
  testWidgets('Tela inicial mostra os campos de usuário e senha', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
