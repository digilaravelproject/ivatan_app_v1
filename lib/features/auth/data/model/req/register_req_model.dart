/*class RegisterReqModel {
  String name;
  String email;
  String password;
  String cnfPassword;
  String phone;

  RegisterReqModel({
    required this.name,
    required this.email,
    required this.password,
    required this.cnfPassword,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': cnfPassword,
      'phone': phone,
    };
  }
}*/




class RegisterReqModel {
  String name;
  String email;
  String phone;
  String username;
  String password;
  String dateOfBirth;
  String occupation;
  List<String> interests;

  RegisterReqModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    required this.occupation,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "username": username,
      "password": password,
      "date_of_birth": dateOfBirth,
      "occupation": occupation,
      "interests": interests,
    };
  }
}

