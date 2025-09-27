// lib/src/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:get_boilerplate/src/models/user_model.dart';
import 'package:get_boilerplate/src/repository/local/user_local.dart';
import 'package:get_boilerplate/src/repository/remote/authentication_repository.dart';

class AuthController extends GetxController {
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final UserLocal _userLocal = UserLocal();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final token = _userLocal.getAccessToken();
    final userData = _userLocal.getUserData();

    if (token.isNotEmpty && userData != null) {
      currentUser.value = userData;
      isAuthenticated.value = true;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.login(email, password);

      if (response.success && response.data != null) {
        final userData = response.data!;
        final token = userData['token'] ?? '';
        final userInfo = userData['user'] ?? {};

        // Save token
        _userLocal.saveAccessToken(token);

        // Create and save user
        final user = User.fromJson(userInfo);
        _userLocal.saveUserData(user);

        currentUser.value = user;
        isAuthenticated.value = true;

        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(
      String name, String email, String password, UserRole role) async {
    try {
      isLoading.value = true;

      final response =
          await _authRepository.register(email, password, name, role);

      if (response.success && response.data != null) {
        final userData = response.data!;
        final token = userData['token'] ?? '';
        final userInfo = userData['user'] ?? {};

        // Save token
        _userLocal.saveAccessToken(token);

        // Create and save user
        final user = User.fromJson(userInfo);
        _userLocal.saveUserData(user);

        currentUser.value = user;
        isAuthenticated.value = true;

        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API
      await _authRepository.logout();

      // Clear local data
      _userLocal.clearUserData();

      currentUser.value = null;
      isAuthenticated.value = false;

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = _userLocal.getRefreshToken();
      if (refreshToken.isEmpty) return false;

      final response = await _authRepository.refreshToken(refreshToken);

      if (response.success && response.data != null) {
        final newToken = response.data!['token'] ?? '';
        _userLocal.saveAccessToken(newToken);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    try {
      isLoading.value = true;

      if (currentUser.value != null) {
        final updatedUser = currentUser.value!.copyWith(
          name: name ?? currentUser.value!.name,
          profilePicture: profilePicture ?? currentUser.value!.profilePicture,
        );

        // Update locally first
        currentUser.value = updatedUser;
        _userLocal.saveUserData(updatedUser);

        // TODO: Call update profile API

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters
  bool get isTeacher => currentUser.value?.isTeacher ?? false;
  bool get isStudent => currentUser.value?.isStudent ?? false;
  String get userName => currentUser.value?.name ?? 'User';
  String get userEmail => currentUser.value?.email ?? '';
  UserRole get userRole => currentUser.value?.role ?? UserRole.student;
}
