import 'package:flutter/material.dart';
// import removed: 'understanding_fire_behavior_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  String _filter = '';

  final List<Map<String, String>> tutorials = [
    {'title': 'Understanding Fire Behavior', 'status': 'Completed'},
    {'title': 'Reading Your Environment', 'status': 'In-Progress'},
    {'title': 'Types of Fire Safety Equipment', 'status': 'Yet-to-start'},
    {'title': 'How to Respond Under Pressure', 'status': 'Completed'},
    {'title': 'Communication in Emergencies', 'status': 'Yet-to-start'},
    {'title': 'Understanding Your Role in Fire Response', 'status': 'In-Progress'},
    {'title': 'Basic First Aid for Fire Incidents', 'status': 'Completed'},
    {'title': 'Evacuation Psychology', 'status': 'Yet-to-start'},
    {'title': 'When to Act and When to Step Back', 'status': 'Completed'},
    {'title': 'After the Fire: Reporting and Review', 'status': 'In-Progress'},
  ];

  @override
  Widget build(BuildContext context) {
    List<String> selectedFilters =
        _filter.isEmpty ? [] : _filter.split(',').toList();

    final filteredTutorials = tutorials.where((tutorial) {
      return selectedFilters.isEmpty || selectedFilters.contains(tutorial['status']);
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/tutorials.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Tutorials', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterOptions(context),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: filteredTutorials.length,
            itemBuilder: (context, index) {
              final tutorial = filteredTutorials[index];
              return _buildTutorialCard(tutorial['title']!, tutorial['status']!);
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
      backgroundColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

  Widget _buildCheckbox(StateSetter setModalState, List<String> selectedFilters, String label) {
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

  Widget _buildTutorialCard(String title, String status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white.withOpacity(0.85),
      child: ListTile(
        leading: Icon(Icons.school, color: _getStatusColor(status)),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        subtitle: Text(status, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward, color: Colors.black),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TutorialDetailPage(title: title),
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

class TutorialDetailPage extends StatelessWidget {
  final String title;

  const TutorialDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Detailed content for "$title"')),
    );
  }
}
