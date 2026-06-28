import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'state/reset_app_state.dart';
import 'theme/reset_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = ResetAppState(
    storage: StorageService(),
    notifications: NotificationService(),
  );
  await appState.initialize();

  runApp(ResetApp(appState: appState));
}

class ResetApp extends StatelessWidget {
  const ResetApp({super.key, required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reset',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: ResetColors.primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: ResetColors.primary,
              secondary: ResetColors.accentBlue,
              surface: ResetColors.surface,
              onSurface: ResetColors.ink,
              onSurfaceVariant: ResetColors.muted,
              outline: ResetColors.border,
            ),
        useMaterial3: true,
        scaffoldBackgroundColor: ResetColors.backgroundBottom,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: ResetColors.ink,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: ResetColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          elevation: 0,
          backgroundColor: ResetColors.surface.withValues(alpha: 0.78),
          indicatorColor: ResetColors.primary.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? ResetColors.primaryDeep : ResetColors.muted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            );
          }),
        ),
      ),
      home: ResetShell(appState: appState),
    );
  }
}

class ResetShell extends StatefulWidget {
  const ResetShell({super.key, required this.appState});

  final ResetAppState appState;

  @override
  State<ResetShell> createState() => _ResetShellState();
}

class _ResetShellState extends State<ResetShell> {
  int _selectedIndex = 0;

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(appState: widget.appState, onChanged: _refresh),
      StatsScreen(appState: widget.appState),
      SettingsScreen(appState: widget.appState, onChanged: _refresh),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail = constraints.maxWidth >= 720;
        final body = IndexedStack(index: _selectedIndex, children: screens);

        if (useNavigationRail) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    key: const ValueKey('reset-navigation-rail'),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    backgroundColor: ResetColors.surface.withValues(alpha: 0.78),
                    indicatorColor: ResetColors.primary.withValues(alpha: 0.14),
                    groupAlignment: -0.76,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bar_chart_outlined),
                        selectedIcon: Icon(Icons.bar_chart),
                        label: Text('Stats'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: ResetColors.border),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: body,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ResetColors.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: ResetColors.border),
                  boxShadow: ResetShadows.panel,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SizedBox(
                    width: double.infinity,
                    child: NavigationBar(
                      key: const ValueKey('reset-bottom-navigation'),
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.bar_chart_outlined),
                          selectedIcon: Icon(Icons.bar_chart),
                          label: 'Stats',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
