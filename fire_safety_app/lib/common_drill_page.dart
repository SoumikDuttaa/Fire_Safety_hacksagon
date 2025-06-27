import 'package:flutter/material.dart';

class CommonDrillPage extends StatefulWidget {
  const CommonDrillPage({super.key});

  @override
  _CommonDrillPageState createState() => _CommonDrillPageState();
}

class _CommonDrillPageState extends State<CommonDrillPage> {
  String _filter = '';

  final List<Map<String, dynamic>> drills = [
    {
      'title': 'Introduction to Fire Safety & Classes of Fire',
      'status': 'In-Progress',
      'scene': 'Scene 1/10',
      'content': 'Understanding the Fire Triangle, Types of Fire Causes',
      'score': 75,
    },
    {
      'title': 'Fire Triangle & Common Fire Causes in Hotels',
      'status': 'Completed',
      'scene': 'Scene 2/10',
      'content': 'Fire triangle explanation and fire causes',
      'score': 90,
    },
    {
      'title': 'Recognizing Fire Alarms and Emergency Signals',
      'status': 'In-Progress',
      'scene': 'Scene 3/10',
      'content': 'How to identify fire alarms',
      'score': 60,
    },
    {
      'title': 'Locating Emergency Exits and Stairwells',
      'status': 'Yet-to-start',
      'scene': 'Scene 4/10',
      'content': 'Finding exits and using stairwells',
      'score': 0,
    },
    {
      'title': 'Evacuation Route walkthrough (no fire scenario)',
      'status': 'Completed',
      'scene': 'Scene 5/10',
      'content': 'Walkthrough the evacuation process',
      'score': 85,
    },
    {
      'title': 'Basic Communication Protocol in Emergencies',
      'status': 'Yet-to-start',
      'scene': 'Scene 6/10',
      'content': 'Communication strategies during an emergency',
      'score': 0,
    },
    {
      'title': 'Fire Safety Quiz (basic)',
      'status': 'In-Progress',
      'scene': 'Scene 7/10',
      'content': 'Basic knowledge testing on fire safety',
      'score': 70,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<String> selectedFilters =
        _filter.isEmpty ? [] : _filter.split(',').toList();

    List<Map<String, dynamic>> filteredDrills = drills.where((drill) {
      return selectedFilters.isEmpty || selectedFilters.contains(drill['status']);
    }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("lib/assets/common_drill.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Common Drill', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => _showFilterOptions(context),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: filteredDrills.length,
            itemBuilder: (context, index) {
              final drill = filteredDrills[index];
              return _buildDrillCard(
                drill['title'],
                drill['status'],
                drill['scene'],
                drill['content'],
                drill['score'],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    List<String> selectedFilters = _filter.split(',').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildCheckbox(setModalState, selectedFilters, 'Completed'),
                _buildCheckbox(setModalState, selectedFilters, 'In-Progress'),
                _buildCheckbox(setModalState, selectedFilters, 'Yet-to-start'),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _filter = selectedFilters.join(','));
                    Navigator.pop(context);
                  },
                  child: const Text('Apply', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCheckbox(
    StateSetter setModalState,
    List<String> selectedFilters,
    String label,
  ) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: selectedFilters.contains(label),
      onChanged: (bool? value) {
        setModalState(() {
          if (value == true) {
            selectedFilters.add(label);
          } else {
            selectedFilters.remove(label);
          }
        });
      },
    );
  }

  Widget _buildDrillCard(
    String title,
    String status,
    String scene,
    String content,
    int score,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white.withOpacity(0.85),
      child: ListTile(
        leading: Icon(Icons.fireplace, color: _getStatusColor(status)),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$scene - $content', style: const TextStyle(color: Colors.black54)),
            Text('Score: $score', style: const TextStyle(color: Colors.black54)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DrillDetailPage(title: title),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In-Progress':
        return Colors.orange;
      case 'Yet-to-start':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

class DrillDetailPage extends StatelessWidget {
  final String title;

  const DrillDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Detailed content for $title')),
    );
  }
}
