class CreateUserReq {
  final String userName;
  final String email;
  final String password;

  CreateUserReq(
      {required this.userName, required this.email, required this.password});
}
