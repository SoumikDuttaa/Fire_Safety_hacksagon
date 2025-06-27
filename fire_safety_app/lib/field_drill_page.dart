import 'package:flutter/material.dart';

class FieldDrillPage extends StatefulWidget {
  const FieldDrillPage({super.key});

  @override
  _FieldDrillPageState createState() => _FieldDrillPageState();
}

class _FieldDrillPageState extends State<FieldDrillPage> {
  String _filter = '';

  final List<Map<String, dynamic>> drills = [
    {
      'title': 'Housekeeping: Spotting and Reporting Fire Hazards',
      'status': 'In-Progress',
    },
    {
      'title': 'Kitchen: Handling a Minor Grease Fire',
      'status': 'Completed',
    },
    {
      'title': 'Security: Directing Crowds Safely to Exits',
      'status': 'In-Progress',
    },
    {
      'title': 'Maintenance: Simulated Power Shutdown',
      'status': 'Yet-to-start',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<String> selectedFilters =
        _filter.isEmpty ? [] : _filter.split(',').toList();

    final filteredDrills = drills.where((drill) {
      return selectedFilters.isEmpty || selectedFilters.contains(drill['status']);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Field Drill', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🔥 Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/field_drill.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // 📄 List content
          SafeArea(
            child: ListView.builder(
              itemCount: filteredDrills.length,
              itemBuilder: (context, index) {
                final drill = filteredDrills[index];
                return _buildDrillCard(drill['title'], drill['status']);
              },
            ),
          ),
        ],
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

  Widget _buildDrillCard(String title, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.warning, color: _getStatusColor(status)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status, style: const TextStyle(color: Colors.black54)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FieldDrillDetailPage(title: title),
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

class FieldDrillDetailPage extends StatelessWidget {
  final String title;

  const FieldDrillDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Detailed content for $title')),
    );
  }
}
