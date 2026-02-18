class Applicant {
  final String id;
  final String name;
  final String position;
  final String experience;
  final String location;
  final String email;
  final String phone;
  final String education;
  final List<String> skills;
  final String cvSummary;
  final String appliedDate;

  Applicant({
    required this.id,
    required this.name,
    required this.position,
    required this.experience,
    required this.location,
    required this.email,
    required this.phone,
    required this.education,
    required this.skills,
    required this.cvSummary,
    required this.appliedDate,
  });
}