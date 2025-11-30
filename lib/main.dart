import 'data/library/libray.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FavoritesBox.openBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: Providers.providers,
      child: CupertinoApp(
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: const MainScreen(),
      ),
    );
  }
}
