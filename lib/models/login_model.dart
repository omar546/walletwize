class LoginModel {
  String? token;
  String? tokenType;

  LoginModel({this.token, this.tokenType});

  LoginModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['token_type'] = this.tokenType;
    return data;
  }
}
