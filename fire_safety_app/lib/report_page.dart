import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_page.dart';
import 'setting.dart';

class ReportPage extends StatelessWidget {
  final String userId;

  const ReportPage({super.key, this.userId = "dummyUser"});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> progressList = [
      {'title': 'Basic Fire Safety Awareness', 'percent': 0.75},
      {'title': 'Fire Extinguishers and Their Uses', 'percent': 0.6},
      {'title': 'Evacuation and Emergency Response', 'percent': 0.5},
      {'title': 'Workplace and Home Fire Safety', 'percent': 0.9},
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF0DC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Score',
                  style: TextStyle(
                    color: Color(0xFF8B2C2C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '28',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '/30',
                              style: TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fire Extinguisher Quiz',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 28 / 30,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Performance Report',
                  style: TextStyle(
                    color: Color(0xFF8B2C2C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                buildBarChart(progressList),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: progressList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF8B2C2C),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircularPercentIndicator(
                              radius: 20,
                              lineWidth: 5,
                              percent: item['percent'] as double,
                              backgroundColor: Colors.grey.shade300,
                              progressColor: const Color(0xFF8B2C2C),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFD09A5B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.article,
                    size: 32,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                _buildNavItem(context, Icons.home, "Home"),
                const SizedBox(width: 16),
                _buildNavItem(context, Icons.settings, "Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Home") {
          Navigator.pushReplacement(
            context,
            _createRoute(const DashboardPage()),
          );
        } else if (label == "Settings") {
          Navigator.pushReplacement(
            context,
            _createRoute(const Setting()), // ✅ FIXED
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Widget buildBarChart(List<Map<String, dynamic>> progressList) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          minY: 0.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white,
              getTooltipItem: (group, _, rod, __) {
                final title = progressList[group.x.toInt()]['title'];
                final percent = (rod.toY * 100).toInt();
                return BarTooltipItem(
                  '$title\n',
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B2C2C),
                  ),
                  children: [
                    TextSpan(
                      text: '$percent%',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.2,
                reservedSize: 35,
                getTitlesWidget: (value, _) => Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 70,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < progressList.length) {
                    final title = progressList[index]['title'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Transform.rotate(
                        angle: 0.0,
                        child: SizedBox(
                          width: 70,
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 0.2,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade300, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: progressList.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data['percent'],
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF8B2C2C),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
