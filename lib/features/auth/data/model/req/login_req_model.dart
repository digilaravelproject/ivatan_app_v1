class LoginReqModel {
  String phone;
  String? firebaseToken;
  String? password;

  LoginReqModel({required this.phone, this.firebaseToken, this.password});

  Map<String, dynamic> toMap() {
    return {'mobile': phone, 'firebase_token': firebaseToken};
  }

  Map<String, dynamic> toPasswordMap() {
    return {'username': phone, 'password': password};
  }
}
