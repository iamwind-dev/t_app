import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/users/data/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.threads = const [],
    this.errorMessage,
    this.isSaving = false,
    this.isFollowUpdating = false,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final List<ThreadItemModel> threads;
  final String? errorMessage;
  final bool isSaving;
  final bool isFollowUpdating;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<ThreadItemModel>? threads,
    String? errorMessage,
    bool? isSaving,
    bool? isFollowUpdating,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      threads: threads ?? this.threads,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isFollowUpdating: isFollowUpdating ?? this.isFollowUpdating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    threads,
    errorMessage,
    isSaving,
    isFollowUpdating,
  ];
}
