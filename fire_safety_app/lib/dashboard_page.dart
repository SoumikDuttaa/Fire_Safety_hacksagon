import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'tutorials_page.dart';
import 'common_drill_page.dart';
import 'field_drill_page.dart';
import 'report_page.dart';
import 'setting.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM').format(_selectedDate);
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'BlazeON',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(formattedDate, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18),
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.offset - 100,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(daysInMonth, (index) {
                                final int day = index + 1;
                                final bool isSelected = day == _selectedDate.day;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = DateTime(now.year, now.month, day);
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? Colors.deepPurple : Colors.grey,
                                          width: isSelected ? 3 : 1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.offset + 100,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildImageCard("TUTORIALS", Colors.deepOrange),
                    const SizedBox(height: 16),
                    _buildImageCard("COMMON DRILL", Colors.teal),
                    const SizedBox(height: 16),
                    _buildImageCard("FIELD DRILL", Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ChatBot feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFD09A5B),
        child: const Icon(Icons.chat, size: 28),
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
              _buildNavItem(context, Icons.article, "Report"),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.home, size: 32, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              _buildNavItem(context, Icons.settings, "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String title, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == "TUTORIALS") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorialPage()));
        } else if (title == "COMMON DRILL") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CommonDrillPage()));
        } else if (title == "FIELD DRILL") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldDrillPage()));
        }
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Report") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage(userId: "dummyUser")));
        } else if (label == "Settings") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const Setting()));
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
}
