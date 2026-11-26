import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/discovery_service.dart';
import '../../domain/models/discovery_profile.dart';

class DiscoveryState {
  final List<DiscoveryProfile> deck;
  final List<DiscoveryProfile> history;
  final bool isLoading;
  final bool isIncognitoEnabled;
  final SwipeResult? latestMatch;

  const DiscoveryState({
    required this.deck,
    required this.history,
    required this.isLoading,
    required this.isIncognitoEnabled,
    this.latestMatch,
  });

  DiscoveryProfile? get currentProfile => deck.isNotEmpty ? deck.first : null;

  DiscoveryState copyWith({
    List<DiscoveryProfile>? deck,
    List<DiscoveryProfile>? history,
    bool? isLoading,
    bool? isIncognitoEnabled,
    SwipeResult? latestMatch,
    bool clearLatestMatch = false,
  }) {
    return DiscoveryState(
      deck: deck ?? this.deck,
      history: history ?? this.history,
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

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_storageKey);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey, val);
    } catch (_) {}
  }
}

final incognitoShieldProvider =
    NotifierProvider<IncognitoNotifier, bool>(IncognitoNotifier.new);

class DiscoveryNotifier extends Notifier<DiscoveryState> {
  IDiscoveryService get _service => ref.read(discoveryServiceProvider);

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

  Future<void> loadDeck({bool? incognito}) async {
    final useIncognito = incognito ?? state.isIncognitoEnabled;
    state = state.copyWith(isLoading: true, isIncognitoEnabled: useIncognito);
    final profiles = await _service.fetchDeck(
      incognitoShield: useIncognito,
    );
    state = state.copyWith(
      deck: profiles,
      isLoading: false,
    );
  }

  Future<SwipeResult?> swipe(SwipeDirection direction) async {
    if (state.deck.isEmpty) return null;

    final targetProfile = state.deck.first;
    final remaining = List<DiscoveryProfile>.from(state.deck)..removeAt(0);
    final updatedHistory = List<DiscoveryProfile>.from(state.history)..add(targetProfile);

    state = state.copyWith(
      deck: remaining,
      history: updatedHistory,
    );

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
    final updatedHistory = List<DiscoveryProfile>.from(state.history)..removeLast();
    final updatedDeck = [lastProfile, ...state.deck];

    state = state.copyWith(
      deck: updatedDeck,
      history: updatedHistory,
    );
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
