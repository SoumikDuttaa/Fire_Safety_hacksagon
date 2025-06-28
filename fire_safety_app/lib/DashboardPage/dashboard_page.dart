  import 'dart:async';
  import 'dart:convert';
  import 'dart:ui';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  import 'user_profile_panel.dart'; // 🔥 Profile Panel
  import '../tutorials_page.dart';
  import '../common_drill_page.dart';
  import '../field_drill_page.dart';
  import '../report_page.dart';
  import '../setting.dart';
  import '../chat_page.dart';

  class UserDashboardPage extends StatefulWidget {
    final String userId;

    const UserDashboardPage({super.key, required this.userId});

    @override
    State<UserDashboardPage> createState() => _UserDashboardPageState();
  }

  class _UserDashboardPageState extends State<UserDashboardPage> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF0DC),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BlazeON',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .get(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() as Map<String, dynamic>?;

                      final base64Image = data?['profile'];
                      final imageProvider = base64Image != null && base64Image != ''
                          ? MemoryImage(base64Decode(base64Image))
                          : const AssetImage('assets/default_avatar.png') as ImageProvider;

                      return GestureDetector(
                        onTap: () {
                          if (data != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => UserProfilePanel(
                                userId: widget.userId,
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                              backgroundColor: Colors.white,
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: Colors.deepOrange,
                                child: Icon(Icons.edit, size: 8, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const FireSafetyCarousel(),
              const SizedBox(height: 24),
              _buildImageCard("TUTORIALS", "lib/assets/tutorials.jpg"),
              const SizedBox(height: 16),
              _buildImageCard("COMMON DRILL", "lib/assets/common_drill.jpg"),
              const SizedBox(height: 16),
              _buildImageCard("FIELD DRILL", "lib/assets/field_drill.jpg"),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(userId: widget.userId),
                ),
              );
            },
            backgroundColor: const Color(0xFFD09A5B),
            child: const Icon(Icons.chat, size: 28),
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

    Widget _buildImageCard(String title, String imagePath) {
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
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
            ),
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => ReportPage(userId: widget.userId)));
          } else if (label == "Settings") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Setting(userId: widget.userId)));
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

  class FireSafetyCarousel extends StatefulWidget {
    const FireSafetyCarousel({super.key});

    @override
    State<FireSafetyCarousel> createState() => _FireSafetyCarouselState();
  }

  class _FireSafetyCarouselState extends State<FireSafetyCarousel> {
    final PageController _pageController = PageController();
    int _currentIndex = 0;
    Timer? _autoSlideTimer;

    final List<Map<String, dynamic>> carouselItems = [
      {
        'icon': Icons.calendar_month,
        'title': "FIRE SAFETY WORKSHOP",
        'subtitle': "Central Park, Patia",
        'date': "31 July",
        'buttonText': "LEARN MORE",
        'onPressed': () {
          debugPrint("Learn More about the workshop");
        },
      },
      {
        'icon': Icons.tips_and_updates,
        'title': "Install smoke alarms",
        'subtitle': "in bedrooms, halls, and every level",
        'date': "Tip of the Day",
        'buttonText': null,
        'onPressed': null,
      },
    ];

    @override
    void initState() {
      super.initState();
      _startAutoSlide();
    }

    void _startAutoSlide() {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          int nextPage = (_currentIndex + 1) % carouselItems.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentIndex = nextPage;
          });
        }
      });
    }

    @override
    void dispose() {
      _pageController.dispose();
      _autoSlideTimer?.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 230,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselItems.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = carouselItems[index];

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'lib/assets/fire_background.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(color: Colors.black.withOpacity(0.4)),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 340),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['subtitle'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['date'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (item['buttonText'] != null) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: item['onPressed'],
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.black,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        minimumSize: const Size(130, 38),
                                      ),
                                      child: Text(
                                        item['buttonText'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(carouselItems.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color.fromARGB(255, 160, 45, 45)
                      : const Color.fromARGB(190, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ],
      );
    }
  }
