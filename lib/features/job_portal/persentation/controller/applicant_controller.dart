import '../../data/model/applicant_model.dart';

class ApplicantController {
  // Private constructor
  ApplicantController._privateConstructor();
  static final ApplicantController _instance = ApplicantController._privateConstructor();
  factory ApplicantController() => _instance;

  // Dummy data - replace with actual API calls
  final List<Applicant> _applicants = [
    Applicant(
      id: '1',
      name: 'Aarav Sharma',
      position: 'Senior Flutter Developer',
      experience: '5 years',
      location: 'Mumbai, India',
      email: 'aarav.sharma@email.com',
      phone: '+91 98765 43210',
      education: 'B.Tech Computer Science, IIT Bombay',
      skills: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'],
      cvSummary: 'Experienced Flutter developer with 5+ years in mobile app development. Led 3 major app launches with 100K+ downloads.',
      appliedDate: '2024-03-15',
    ),
    Applicant(
      id: '2',
      name: 'Priya Patel',
      position: 'UX Designer',
      experience: '3 years',
      location: 'Bangalore, India',
      email: 'priya.patel@email.com',
      phone: '+91 87654 32109',
      education: 'M.Des Interaction Design, NID',
      skills: ['Figma', 'Adobe XD', 'User Research', 'Wireframing', 'Prototyping'],
      cvSummary: 'Creative UX designer with 3 years of experience in fintech and e-commerce. Created designs that increased user engagement by 40%.',
      appliedDate: '2024-03-14',
    ),
    Applicant(
      id: '3',
      name: 'Rahul Verma',
      position: 'Backend Engineer',
      experience: '4 years',
      location: 'Delhi, India',
      email: 'rahul.verma@email.com',
      phone: '+91 76543 21098',
      education: 'B.E. Computer Science, DTU',
      skills: ['Node.js', 'Python', 'MongoDB', 'AWS', 'Docker'],
      cvSummary: 'Backend specialist with experience in building scalable microservices. Reduced API response time by 60%.',
      appliedDate: '2024-03-13',
    ),
    Applicant(
      id: '4',
      name: 'Ananya Singh',
      position: 'Product Manager',
      experience: '6 years',
      location: 'Pune, India',
      email: 'ananya.singh@email.com',
      phone: '+91 65432 10987',
      education: 'MBA, IIM Ahmedabad',
      skills: ['Product Strategy', 'Agile', 'Roadmapping', 'Data Analysis', 'Team Leadership'],
      cvSummary: 'Results-driven Product Manager with 6 years of experience. Launched 5 successful B2B SaaS products.',
      appliedDate: '2024-03-12',
    ),
  ];

  // Get all applicants
  List<Applicant> getAllApplicants() {
    return _applicants;
  }

  // Get single applicant by ID
  Applicant? getApplicantById(String id) {
    try {
      return _applicants.firstWhere((applicant) => applicant.id == id);
    } catch (e) {
      return null;
    }
  }
}