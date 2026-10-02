import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/local_store.dart';
import 'domain/app_state.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/glucose/glucose_list_page.dart';
import 'features/insulin/insulin_page.dart';
import 'features/more/more_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'navigation.dart';

/// Racine de l'application (WBS lot 4.2 : navigation).
class DiabTrackApp extends StatefulWidget {
  const DiabTrackApp({super.key, required this.store});

  final LocalStore store;

  @override
  State<DiabTrackApp> createState() => _DiabTrackAppState();
}

class _DiabTrackAppState extends State<DiabTrackApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(widget.store);
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiabTrack',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          if (!_state.ready) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!_state.onboardingDone) {
            return OnboardingPage(
              onDone: _state.completeOnboarding,
            );
          }
          return HomeShell(state: _state);
        },
      ),
    );
  }
}

/// Coquille principale avec la navigation par onglets (4 onglets).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _titles = ['DiabTrack', 'Mes mesures', 'Traitement', 'Plus'];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(state: widget.state),
      GlucoseListPage(state: widget.state),
      InsulinPage(state: widget.state),
      MorePage(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          if (_tab == 0)
            ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => openGlucoseEditor(context, widget.state),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Mesure'),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) => IndexedStack(index: _tab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Mesures',
          ),
          NavigationDestination(
            icon: Icon(Icons.vaccines_outlined),
            selectedIcon: Icon(Icons.vaccines),
            label: 'Traitement',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}
