part of 'profile_cubit.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? error;
  final String? serverUrl;

  const ProfileState({
    required this.status,
    this.user,
    this.error,
    this.serverUrl,
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? error,
    String? serverUrl,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }

  @override
  List<Object?> get props => [status, user, error, serverUrl];
}
