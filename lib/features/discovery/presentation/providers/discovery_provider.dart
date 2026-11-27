import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/discovery_service.dart';
import '../../domain/models/discovery_profile.dart';

class DiscoveryState {
  final List<DiscoveryProfile> deck;
  final List<DiscoveryProfile> history;
  final Map<String, SwipeDirection> cachedSwipes;
  final bool isLoading;
  final bool isIncognitoEnabled;
  final SwipeResult? latestMatch;

  const DiscoveryState({
    required this.deck,
    required this.history,
    this.cachedSwipes = const {},
    required this.isLoading,
    required this.isIncognitoEnabled,
    this.latestMatch,
  });

  DiscoveryProfile? get currentProfile => deck.isNotEmpty ? deck.first : null;

  DiscoveryState copyWith({
    List<DiscoveryProfile>? deck,
    List<DiscoveryProfile>? history,
    Map<String, SwipeDirection>? cachedSwipes,
    bool? isLoading,
    bool? isIncognitoEnabled,
    SwipeResult? latestMatch,
    bool clearLatestMatch = false,
  }) {
    return DiscoveryState(
      deck: deck ?? this.deck,
      history: history ?? this.history,
      cachedSwipes: cachedSwipes ?? this.cachedSwipes,
      isLoading: isLoading ?? this.isLoading,
      isIncognitoEnabled: isIncognitoEnabled ?? this.isIncognitoEnabled,
      latestMatch: clearLatestMatch ? null : (latestMatch ?? this.latestMatch),
    );
  }
}

final discoveryServiceProvider = Provider<IDiscoveryService>((ref) {
  return MockDiscoveryService();
});

class IncognitoNotifier extends Notifier<bool> {
  static const String _storageKey = 'date2_incognito_shield_v1';

  @override
  bool build() {
    _loadFromStorage();
    return false;
  }

  Future<SharedPreferences?> _getPrefs() async {
    final injected = ref.read(optionalSharedPreferencesProvider);
    if (injected != null) return injected;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _getPrefs();
      final saved = prefs?.getBool(_storageKey);
      if (saved != null && saved != state) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = !state;
    state = next;
    await _saveToStorage(next);
  }

  Future<void> set(bool val) async {
    state = val;
    await _saveToStorage(val);
  }

  Future<void> _saveToStorage(bool val) async {
    try {
      final prefs = await _getPrefs();
      await prefs?.setBool(_storageKey, val);
    } catch (_) {}
  }
}

final incognitoShieldProvider =
    NotifierProvider<IncognitoNotifier, bool>(IncognitoNotifier.new);

class DiscoveryNotifier extends Notifier<DiscoveryState> {
  static const String _swipeCacheKey = 'date2_discovery_swipe_cache_v1';

  IDiscoveryService get _service => ref.read(discoveryServiceProvider);

  Future<SharedPreferences?> _getPrefs() async {
    final injected = ref.read(optionalSharedPreferencesProvider);
    if (injected != null) return injected;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  DiscoveryState build() {
    final incognito = ref.watch(incognitoShieldProvider);
    Future.microtask(() => loadDeck(incognito: incognito));
    return DiscoveryState(
      deck: const [],
      history: const [],
      isLoading: true,
      isIncognitoEnabled: incognito,
    );
  }

  Future<Map<String, SwipeDirection>> _loadCachedSwipes() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs?.getString(_swipeCacheKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          SwipeDirection.values.firstWhere(
            (e) => e.name == value,
            orElse: () => SwipeDirection.left,
          ),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCachedSwipes(Map<String, SwipeDirection> cache) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      final encoded = jsonEncode(
        cache.map((key, value) => MapEntry(key, value.name)),
      );
      await prefs.setString(_swipeCacheKey, encoded);
    } catch (_) {}
  }

  Future<void> clearSwipeCache() async {
    state = state.copyWith(cachedSwipes: const {});
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_swipeCacheKey);
    } catch (_) {}
  }

  Future<void> loadDeck({bool? incognito, bool resetCache = false}) async {
    final useIncognito = incognito ?? state.isIncognitoEnabled;
    state = state.copyWith(isLoading: true, isIncognitoEnabled: useIncognito);

    if (resetCache) {
      await clearSwipeCache();
    }

    final cachedSwipes =
        resetCache ? <String, SwipeDirection>{} : await _loadCachedSwipes();

    int? minAge;
    int? maxAge;
    int? maxDistanceKm;
    try {
      final prefs = ref.read(optionalSharedPreferencesProvider);
      if (prefs != null) {
        final profile = ref.read(onboardingProvider).profile;
        minAge = profile.minAgePreference;
        maxAge = profile.maxAgePreference;
        maxDistanceKm = profile.maxDistanceKm;
      }
    } catch (_) {}

    final profiles = await _service.fetchDeck(
      incognitoShield: useIncognito,
      minAge: minAge,
      maxAge: maxAge,
      maxDistanceKm: maxDistanceKm,
      excludedIds: cachedSwipes.keys.toSet(),
    );

    state = state.copyWith(
      deck: profiles,
      cachedSwipes: cachedSwipes,
      isLoading: false,
    );
  }

  Future<SwipeResult?> swipe(SwipeDirection direction) async {
    if (state.deck.isEmpty) return null;

    final targetProfile = state.deck.first;
    final remaining = List<DiscoveryProfile>.from(state.deck)..removeAt(0);
    final updatedHistory = List<DiscoveryProfile>.from(state.history)
      ..add(targetProfile);
    final updatedCache = Map<String, SwipeDirection>.from(state.cachedSwipes)
      ..[targetProfile.id] = direction;

    state = state.copyWith(
      deck: remaining,
      history: updatedHistory,
      cachedSwipes: updatedCache,
    );
    await _saveCachedSwipes(updatedCache);

    final result = await _service.sendSwipe(
      profileId: targetProfile.id,
      direction: direction,
    );

    if (result.isMatch) {
      state = state.copyWith(latestMatch: result);
    }
    return result;
  }

  void undoSwipe() {
    if (state.history.isEmpty) return;
    final lastProfile = state.history.last;
    final updatedHistory = List<DiscoveryProfile>.from(state.history)
      ..removeLast();
    final updatedDeck = [lastProfile, ...state.deck];
    final updatedCache = Map<String, SwipeDirection>.from(state.cachedSwipes)
      ..remove(lastProfile.id);

    state = state.copyWith(
      deck: updatedDeck,
      history: updatedHistory,
      cachedSwipes: updatedCache,
    );
    _saveCachedSwipes(updatedCache);
  }

  void clearMatchDialog() {
    state = state.copyWith(clearLatestMatch: true);
  }

  void toggleIncognito(bool enabled) {
    ref.read(incognitoShieldProvider.notifier).set(enabled);
    state = state.copyWith(isIncognitoEnabled: enabled);
    loadDeck(incognito: enabled);
  }
}

final discoveryProvider =
    NotifierProvider<DiscoveryNotifier, DiscoveryState>(DiscoveryNotifier.new);
