import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';

final _authRequestProvider = Provider<AuthRequest>((_) => AuthRequest());

sealed class LogoutResult {
  const LogoutResult();
}

class LogoutSuccess extends LogoutResult {
  const LogoutSuccess();
}

class LogoutFailure extends LogoutResult {
  const LogoutFailure(this.message);
  final String message;
}

class ProfileState {
  const ProfileState({
    this.appVersionInfo = '',
    this.authenticated = false,
    this.currentUser,
  });
  final String appVersionInfo;
  final bool authenticated;
  final User? currentUser;

  ProfileState copyWith({
    String? appVersionInfo,
    bool? authenticated,
    User? currentUser,
  }) => ProfileState(
    appVersionInfo: appVersionInfo ?? this.appVersionInfo,
    authenticated: authenticated ?? this.authenticated,
    currentUser: currentUser ?? this.currentUser,
  );
}

class ProfileController extends AsyncNotifier<ProfileState> {
  StreamSubscription? _authSub;

  @override
  Future<ProfileState> build() async {
    ref.onDispose(() => _authSub?.cancel());
    return _load();
  }

  Future<ProfileState> _load() async {
    final pkg = await PackageInfo.fromPlatform();
    final version = '${pkg.version}(${pkg.buildNumber})';
    final authed = AuthServices.authenticated();
    User? user;
    if (authed) {
      user = await AuthServices.getCurrentUser(force: true);
    } else {
      _listenToAuthChange();
    }
    return ProfileState(
      appVersionInfo: version,
      authenticated: authed,
      currentUser: user,
    );
  }

  void _listenToAuthChange() {
    _authSub?.cancel();
    _authSub = AuthServices.listenToAuthState().listen((event) async {
      if (event != null && event) {
        final user = await AuthServices.getCurrentUser(force: true);
        state = AsyncData(
          (state.valueOrNull ?? const ProfileState()).copyWith(
            authenticated: true,
            currentUser: user,
          ),
        );
        _authSub?.cancel();
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<LogoutResult> logout() async {
    try {
      await ref.read(_authRequestProvider).logoutRequest();
    } catch (_) {
      // Ignore network / request failures during logout to ensure user is not stuck
    }
    try {
      await AuthServices.logout();
      state = AsyncData(
        (state.valueOrNull ?? const ProfileState()).copyWith(
          authenticated: false,
          currentUser: null,
        ),
      );
      return const LogoutSuccess();
    } catch (e) {
      return LogoutFailure('$e');
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileState>(
      ProfileController.new,
    );
