class Job {
  final int id;
  final String companyName;
  final String companyLogo;
  final String position;
  final String location;
  final String type;
  final String description;
  final int daysLeft;
  final double salary;
  final String experience;
  final String workingHours;
  final int vacancies;
  final List<String> skillsRequired;
  final List<String> requirements;
  final List<String> benefits;
  final String companyIndustry;
  final String companyDescription;
  final String companySize;
  final String companyFounded;
  final String companyLocation;
  final bool isBookmarked;

  Job({
    required this.id,
    required this.companyName,
    required this.companyLogo,
    required this.position,
    required this.location,
    required this.type,
    required this.description,
    required this.daysLeft,
    required this.salary,
    required this.experience,
    required this.workingHours,
    required this.vacancies,
    required this.skillsRequired,
    required this.requirements,
    required this.benefits,
    required this.companyIndustry,
    required this.companyDescription,
    required this.companySize,
    required this.companyFounded,
    required this.companyLocation,
    this.isBookmarked = false,
  });

  // Copy with method for immutability
  Job copyWith({
    int? id,
    String? companyName,
    String? companyLogo,
    String? position,
    String? location,
    String? type,
    String? description,
    int? daysLeft,
    double? salary,
    String? experience,
    String? workingHours,
    int? vacancies,
    List<String>? skillsRequired,
    List<String>? requirements,
    List<String>? benefits,
    String? companyIndustry,
    String? companyDescription,
    String? companySize,
    String? companyFounded,
    String? companyLocation,
    bool? isBookmarked,
  }) {
    return Job(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      position: position ?? this.position,
      location: location ?? this.location,
      type: type ?? this.type,
      description: description ?? this.description,
      daysLeft: daysLeft ?? this.daysLeft,
      salary: salary ?? this.salary,
      experience: experience ?? this.experience,
      workingHours: workingHours ?? this.workingHours,
      vacancies: vacancies ?? this.vacancies,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      companyIndustry: companyIndustry ?? this.companyIndustry,
      companyDescription: companyDescription ?? this.companyDescription,
      companySize: companySize ?? this.companySize,
      companyFounded: companyFounded ?? this.companyFounded,
      companyLocation: companyLocation ?? this.companyLocation,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}