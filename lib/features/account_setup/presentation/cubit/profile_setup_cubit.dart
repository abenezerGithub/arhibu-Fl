import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ProfileSetupState {
  final int currentStep;
  final Map<String, dynamic> formData;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final bool isProfileComplete;

  ProfileSetupState({
    this.currentStep = 0,
    this.formData = const {},
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isProfileComplete = false,
  });

  ProfileSetupState copyWith({
    int? currentStep,
    Map<String, dynamic>? formData,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool? isProfileComplete,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  static const String _apiUrl =
      'https://arhibu-be.onrender.com/api/user/profile';
  final http.Client _httpClient;

  ProfileSetupCubit({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      super(ProfileSetupState());

  void nextStep() {
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void updateFormData(Map<String, dynamic> newData) {
    final updatedData = Map<String, dynamic>.from(state.formData);
    updatedData.addAll(newData);
    emit(state.copyWith(formData: updatedData));
  }

  Future<String?> _getImageBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        print('Image file does not exist: $imagePath');
        return null;
      }
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error reading image file: $e');
      return null;
    }
  }

  Future<void> submitProfile() async {
    if (!_isFormComplete()) {
      emit(
        state.copyWith(
          errorMessage: 'Please complete all steps before submitting',
          isSuccess: false,
        ),
      );
      return;
    }

    // TODO:  to be integrated with backend after abeni fixed the fields
    /*
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));

    try {
      final profile = state.formData['profile'] ?? {};
      final imagePath = profile['userPicture'] as String?;
      
      if (imagePath == null || imagePath.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Profile image is required',
            isSuccess: false,
          ),
        );
        return;
      }

      final base64Image = await _getImageBase64(imagePath);
      if (base64Image == null) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Could not read profile image',
            isSuccess: false,
          ),
        );
        return;
      }

      final apiData = _transformFormDataToApiFormat();
      apiData['userPicture'] = base64Image;

      print('Sending API data with base64 image');
      final response = await _httpClient.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(apiData),
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          state.copyWith(
            isSuccess: true,
            isLoading: false,
            isProfileComplete: true,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: errorData['message'] ?? 'Failed to update profile',
            isSuccess: false,
            isProfileComplete: false,
          ),
        );
      }
    } catch (e) {
      print('Error submitting profile: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
          isSuccess: false,
          isProfileComplete: false,
        ),
      );
    }
    */


    emit(
      state.copyWith(
        isSuccess: true,
        isLoading: false,
        isProfileComplete: true,
      ),
    );
  }

  Map<String, dynamic> _transformFormDataToApiFormat() {

    final personalInfo = state.formData['personal_info'] ?? {};
    final location = state.formData['location'] ?? {};
    final lifestyle = state.formData['lifestyle'] ?? {};
    final profile = state.formData['profile'] ?? {};
    final roomPreferences = state.formData['room_preferences'] ?? {};
    print('Profile data: $profile');
    print('Profile image path: ${profile['userPicture']}');


    return {
      "fullname": personalInfo['full_name'] ?? '',
      "userPicture":
          "", 
      "verificationDocs": [], 
      "website": "https://arhibu.com", //just dummy data
      "age": int.tryParse(personalInfo['age']?.toString() ?? '') ?? 0,
      "sex": personalInfo['gender'] ?? '',
      "nationality": personalInfo['home_town'] ?? '',
      "education": personalInfo['occupation'] ?? '',
      "bio": roomPreferences['description'] ?? '',
      "location":
          "${location['city'] ?? ''}, ${(location['neighborhoods'] as List?)?.join(', ') ?? ''}",

      "state": personalInfo['state'] ?? '',
      "relationship_status": personalInfo['relationship_status'] ?? '',
      "cleanliness": lifestyle['cleanliness'] ?? '',
      "work_hours": lifestyle['work_hours'] ?? '',
      "sleep_hours": lifestyle['sleep_hours'] ?? '',
      "tobacco_relationship": lifestyle['tobacco_relationship'] ?? '',
      "alcohol_relationship": lifestyle['alcohol_relationship'] ?? '',
      "room_city": roomPreferences['room_city'] ?? '',
      "room_subcity": roomPreferences['room_subcity'] ?? '',
      "bedrooms":
          int.tryParse(roomPreferences['bedrooms']?.toString() ?? '') ?? 0,
      "bathrooms":
          int.tryParse(roomPreferences['bathrooms']?.toString() ?? '') ?? 0,
      "furniture": roomPreferences['furniture'] ?? '',
      "apartment_type": roomPreferences['apartment_type'] ?? '',
      "amenities": roomPreferences['amenities'] ?? [],
    };
  }

  bool _isFormComplete() {
    final personalInfo = state.formData['personal_info'] ?? {};
    final location = state.formData['location'] ?? {};
    final lifestyle = state.formData['lifestyle'] ?? {};
    final profile = state.formData['profile'] ?? {};
    final roomPreferences = state.formData['room_preferences'] ?? {};


    print('Checking form completion:');
    print('Personal Info: $personalInfo');
    print('Location: $location');
    print('Lifestyle: $lifestyle');
    print('Profile: $profile');
    print('Room Preferences: $roomPreferences');

    if (personalInfo['full_name']?.toString().isEmpty ?? true) {
      print('Missing full_name');
      return false;
    }
    if (personalInfo['age']?.toString().isEmpty ?? true) {
      print('Missing age');
      return false;
    }
    if (personalInfo['gender']?.toString().isEmpty ?? true) {
      print('Missing gender');
      return false;
    }
    if (personalInfo['occupation']?.toString().isEmpty ?? true) {
      print('Missing occupation');
      return false;
    }
    if (personalInfo['relationship_status']?.toString().isEmpty ?? true) {
      print('Missing relationship_status');
      return false;
    }
    if (personalInfo['home_town']?.toString().isEmpty ?? true) {
      print('Missing home_town');
      return false;
    }

    if ((location['neighborhoods'] as List?)?.isEmpty ?? true) {
      print('Missing neighborhoods');
      return false;
    }
    if (lifestyle['cleanliness']?.toString().isEmpty ?? true) {
      print('Missing cleanliness');
      return false;
    }
    if (lifestyle['work_hours']?.toString().isEmpty ?? true) {
      print('Missing work_hours');
      return false;
    }
    if (lifestyle['sleep_hours']?.toString().isEmpty ?? true) {
      print('Missing sleep_hours');
      return false;
    }
    if (lifestyle['tobacco_relationship']?.toString().isEmpty ?? true) {
      print('Missing tobacco_relationship');
      return false;
    }
    if (lifestyle['alcohol_relationship']?.toString().isEmpty ?? true) {
      print('Missing alcohol_relationship');
      return false;
    }
    if (profile['userPicture']?.toString().isEmpty ?? true) {
      print('Missing userPicture');
      return false;
    }
    if (roomPreferences['bedrooms']?.toString().isEmpty ?? true) {
      print('Missing bedrooms');
      return false;
    }
    if (roomPreferences['bathrooms']?.toString().isEmpty ?? true) {
      print('Missing bathrooms');
      return false;
    }
    if (roomPreferences['description']?.toString().isEmpty ?? true) {
      print('Missing description');
      return false;
    }

    print('All form fields are complete!');
    return true;
  }

  void reset() {
    emit(ProfileSetupState());
  }

  @override
  Future<void> close() {
    _httpClient.close();
    return super.close();
  }
}
