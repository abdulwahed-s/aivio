import 'package:aivio/core/services/profile_service.dart';
import 'package:aivio/data/model/user_profile.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService(),
      super(ProfileInitial());

  Future<void> loadProfile(String uid) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileService.getUserProfile(uid);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfileLoading());

      try {
        await _profileService.updateUsername(uid, newUsername);

        emit(ProfileLoaded(currentProfile.copyWith(username: newUsername)));
      } catch (e) {
        emit(ProfileError(e.toString()));

        emit(ProfileLoaded(currentProfile));
      }
    }
  }

  Future<void> updateProfileImage(String uid, XFile imageFile) async {
    if (state is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.name;

        final downloadUrl = await _profileService.uploadProfileImage(
          uid,
          bytes,
          fileName,
        );

        final currentProfile = (state is ProfileLoaded)
            ? (state as ProfileLoaded).profile
            : await _profileService.getUserProfile(uid);

        emit(ProfileLoaded(currentProfile.copyWith(photoUrl: downloadUrl)));
      } catch (e) {
        emit(ProfileError(e.toString()));

        loadProfile(uid);
      }
    }
  }
}
