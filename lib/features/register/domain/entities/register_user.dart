class RegisterUserEntity {
  final String fullName;
  final String username;
  final String gender;
  final DateTime birthday;
  final String email;
  final String password;

  const RegisterUserEntity({
    required this.fullName,
    required this.username,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.password,
  });
}
