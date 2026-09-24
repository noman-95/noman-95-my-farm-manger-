import 'package:flutter_test/flutter_test.dart';
import 'package:farm_manager_premium/main.dart';
void main(){testWidgets('app starts',(tester) async {await tester.pumpWidget(const FarmApp());expect(find.text('My Farm'),findsOneWidget);});}
