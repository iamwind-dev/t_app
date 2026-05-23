import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.isLoading = false,
    this.hidePassword = true,
    this.errorMessage,
    this.gender,
    this.birthday,
  });

  final bool isLoading;
  final bool hidePassword;
  final String? errorMessage;
  final String? gender;
  final DateTime? birthday;

  RegisterState copyWith({
    bool? isLoading,
    bool? hidePassword,
    String? errorMessage,
    String? gender,
    DateTime? birthday,
    bool clearError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      hidePassword: hidePassword ?? this.hidePassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
    );
  }

  @override
  List<Object?> get props => [isLoading, hidePassword, errorMessage, gender, birthday];
}
