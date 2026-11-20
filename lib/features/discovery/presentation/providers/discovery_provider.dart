import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool val) => state = val;
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
