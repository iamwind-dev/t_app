import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/users/data/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.threads = const [],
    this.followerPreviews = const [],
    this.errorMessage,
    this.isSaving = false,
    this.isFollowUpdating = false,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final List<ThreadItemModel> threads;
  final List<UserProfile> followerPreviews;
  final String? errorMessage;
  final bool isSaving;
  final bool isFollowUpdating;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<ThreadItemModel>? threads,
    List<UserProfile>? followerPreviews,
    String? errorMessage,
    bool? isSaving,
    bool? isFollowUpdating,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      threads: threads ?? this.threads,
      followerPreviews: followerPreviews ?? this.followerPreviews,
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
    followerPreviews,
    errorMessage,
    isSaving,
    isFollowUpdating,
  ];
}
