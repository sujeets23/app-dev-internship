import 'dart:async';
import '../domain/models/auth_state.dart';

abstract class IAuthRepository {
  Future<UsernameAvailabilityStatus> checkUsernameAvailability(String username);
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  });
  Future<bool> loginUser({
    required String identifier,
    required String password,
  });
  Future<EmailOtpStatus> verifyEmailOtp(String email, String enteredOtp);
  Future<bool> sendPasswordResetOtp(String email);
  Future<bool> resetPassword(String email, String newPassword);
}

class MockAuthRepository implements IAuthRepository {
  static const Set<String> _takenUsernames = {
    'admin',
    'waseem',
    'alex',
    'date2',
    'support',
    'moderator',
    'official',
    'ananya',
  };

  static const String demoOtp = '492186';

  @override
  Future<UsernameAvailabilityStatus> checkUsernameAvailability(
    String username,
  ) async {
    final clean = username.trim().toLowerCase();
    if (clean.length < 3) return UsernameAvailabilityStatus.none;

    // Simulate network roundtrip latency
    await Future.delayed(const Duration(milliseconds: 350));

    if (_takenUsernames.contains(clean)) {
      return UsernameAvailabilityStatus.taken;
    }
    return UsernameAvailabilityStatus.available;
  }

  @override
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> loginUser({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Accepts any valid password length >= 6 for mock frontend testing
    return password.length >= 6;
  }

  @override
  Future<EmailOtpStatus> verifyEmailOtp(
    String email,
    String enteredOtp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Testing triggers for various error states
    if (enteredOtp == '000000') {
      return EmailOtpStatus.expiredOtp;
    } else if (enteredOtp == '888888') {
      return EmailOtpStatus.serviceUnavailable;
    } else if (enteredOtp == '999999') {
      return EmailOtpStatus.deliveryFailed;
    } else if (enteredOtp == demoOtp || enteredOtp == '123456') {
      return EmailOtpStatus.success;
    } else {
      return EmailOtpStatus.invalidOtp;
    }
  }

  @override
  Future<bool> sendPasswordResetOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
