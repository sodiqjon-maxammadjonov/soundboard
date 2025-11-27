import 'package:soundboard/ui/view/main/main_screen.dart';
import 'data/library/libray.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      home: MainScreen(),
    );
  }
}
