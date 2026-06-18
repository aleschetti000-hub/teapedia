import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart' show DiaryScreen, DiaryScreenState;

void main() {
  runApp(const TeapediaApp());
}

class TeapediaApp extends StatelessWidget {
  const TeapediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teapedia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const _NoOverscrollBehavior(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Ogni tab ha il proprio Navigator: la bottom bar resta visibile
  // durante la navigazione interna (home → categoria → dettaglio).
  final _exploreKey = GlobalKey<NavigatorState>();
  final _diaryKey = GlobalKey<NavigatorState>();

  // Permette di chiamare reload() sulla DiaryScreen da MainShell (step D)
  final _diaryScreenKey = GlobalKey<DiaryScreenState>();

  GlobalKey<NavigatorState> get _activeKey =>
      _currentIndex == 0 ? _exploreKey : _diaryKey;

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // Tap sul tab già attivo → torna alla root del tab
      _activeKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
      // Ricarica il diario ogni volta che si passa al tab Diario
      if (index == 1) {
        _diaryScreenKey.currentState?.reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Intercetta il tasto back fisico: prima svuota il navigator del tab,
      // poi lascia che il sistema gestisca il pop (che chiuderebbe l'app).
      canPop: !(_activeKey.currentState?.canPop() ?? false),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _activeKey.currentState?.maybePop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Navigator(
              key: _exploreKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            ),
            Navigator(
              key: _diaryKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => DiaryScreen(
                  key: _diaryScreenKey,
                  onGoToExplore: () => setState(() => _currentIndex = 0),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Esplora',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Diario',
            ),
          ],
        ),
      ),
    );
  }
}

// Estende MaterialScrollBehavior (non ScrollBehavior base) per mantenere
// il drag del mouse su macOS/desktop, rimuovendo solo il glow Android.
class _NoOverscrollBehavior extends MaterialScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
