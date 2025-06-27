import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'report_page.dart';

class Setting extends StatefulWidget {
  const Setting({super.key}); // ❌ Removed userId

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String _currentTab = "Settings";

  final List<Map<String, String>> helpOptions = [
    {
      'title': 'Customer Support',
      'description': 'Reach out for assistance with any issue or concern.',
    },
    {
      'title': 'Your Queries',
      'description': 'View your submitted questions and their responses.',
    },
    {
      'title': 'Frequently Asked Questions',
      'description': 'Quick answers to common issues and information.',
    },
  ];

  void _navigateTo(String label) {
    if (label == "Report") {
      Navigator.pushReplacement(
        context,
        _createRoute(const ReportPage(userId: "dummyUser"), fromLeft: true),
      );
    } else if (label == "Home") {
      Navigator.pushReplacement(
        context,
        _createRoute(const DashboardPage(), fromLeft: true),
      );
    }
  }

  void _showComingSoonDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text("This page is coming soon or not yet implemented."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFD09A5B),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF8B2C2C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: helpOptions.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final item = helpOptions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Color(0xFF8B2C2C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item['description']!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onTap: () => _showComingSoonDialog(item['title']!),
                    );
                  },
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
              _buildNavItem("Report", Icons.article),
              const SizedBox(width: 16),
              _buildNavItem("Home", Icons.home),
              const SizedBox(width: 16),
              _buildNavItem("Settings", Icons.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon) {
    final isSelected = label == _currentTab;

    return GestureDetector(
      onTap: () {
        if (!isSelected) _navigateTo(label);
      },
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.orange, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 32, color: Colors.orange),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
    );
  }

  Route _createRoute(Widget page, {bool fromLeft = false}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = Offset(fromLeft ? -1.0 : 1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
