import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/charada/presentation/screens/charada_screen.dart';
import 'features/tools/presentation/screens/tools_screen.dart';
import 'features/lab/presentation/screens/lab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BoliteroApp());
}

class BoliteroApp extends StatelessWidget {
  const BoliteroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolitero Libre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.canvas,
          primary: AppColors.gold,
          secondary: AppColors.turquoise,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CharadaScreen(),
    ToolsScreen(),
    LabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.canvas,
        indicatorColor: AppColors.gold.withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.casino, color: AppColors.gold),
            label: 'Resultados',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.gold),
            label: 'Charada',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.calculate, color: AppColors.gold),
            label: 'Herramientas',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.science, color: AppColors.gold),
            label: 'Mi Lab',
          ),
        ],
      ),
    );
  }
}
