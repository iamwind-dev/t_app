import 'package:equatable/equatable.dart';
import 'package:t_app/features/users/data/user_profile.dart';

enum SearchUsersStatus { initial, loading, loaded, empty, failure }

class SearchUsersState extends Equatable {
  const SearchUsersState({
    this.status = SearchUsersStatus.initial,
    this.query = '',
    this.result,
    this.errorMessage,
    this.isUpdatingFollow = false,
  });

  final SearchUsersStatus status;
  final String query;
  final UserProfile? result;
  final String? errorMessage;
  final bool isUpdatingFollow;

  SearchUsersState copyWith({
    SearchUsersStatus? status,
    String? query,
    UserProfile? result,
    String? errorMessage,
    bool? isUpdatingFollow,
    bool clearError = false,
  }) {
    return SearchUsersState(
      status: status ?? this.status,
      query: query ?? this.query,
      result: result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isUpdatingFollow: isUpdatingFollow ?? this.isUpdatingFollow,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    result,
    errorMessage,
    isUpdatingFollow,
  ];
}
