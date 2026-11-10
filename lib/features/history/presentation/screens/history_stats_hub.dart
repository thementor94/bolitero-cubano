import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import 'history_screen.dart';

class HistoryStatsHub extends StatefulWidget {
  const HistoryStatsHub({super.key});

  @override
  State<HistoryStatsHub> createState() => _HistoryStatsHubState();
}

class _HistoryStatsHubState extends State<HistoryStatsHub> with SingleTickerProviderStateMixin {
  late TabController _hubTabController;

  @override
  void initState() {
    super.initState();
    _hubTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _hubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: TabBarView(
        controller: _hubTabController,
        children: const [
          HistoryScreen(),
          StatsScreen(),
        ],
      ),
      bottomSheet: Container(
        height: 40,
        color: AppColors.canvas,
        child: TabBar(
          controller: _hubTabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "📅 Historial"),
            Tab(text: "📊 Estadísticas"),
          ],
        ),
      ),
    );
  }
}
