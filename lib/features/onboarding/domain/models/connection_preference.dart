/// Connection Preferences model
class ConnectionPreference {
  final List<String> intents;

  const ConnectionPreference({
    this.intents = const [],
  });

  bool get hasSelection => intents.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'intents': intents,
      };

  factory ConnectionPreference.fromJson(Map<String, dynamic> json) =>
      ConnectionPreference(
        intents: (json['intents'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  ConnectionPreference copyWith({
    List<String>? intents,
  }) {
    return ConnectionPreference(
      intents: intents ?? this.intents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionPreference &&
          runtimeType == other.runtimeType &&
          _listEquals(intents, other.intents);

  @override
  int get hashCode => intents.hashCode;

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
