class Staff {
  final String id;
  final String name;
  final String doj;
  final String email;
  final String phone;
  final String idProof;
  final String position;
  final String shift;
  final int progress;
  final String profile;
  final bool isActive;

  Staff({
    required this.id,
    required this.name,
    required this.doj,
    required this.email,
    required this.phone,
    required this.idProof,
    required this.position,
    required this.shift,
    required this.progress,
    required this.profile,
    required this.isActive, // ✅ Add this
  });
}