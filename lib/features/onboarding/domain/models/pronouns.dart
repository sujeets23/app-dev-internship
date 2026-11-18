/// Pronouns domain model
class Pronouns {
  final String option;
  final String? customPronouns;

  const Pronouns({
    required this.option,
    this.customPronouns,
  });

  bool get isCustom => option == 'Custom pronouns';

  String get displayValue {
    if (isCustom && customPronouns != null && customPronouns!.trim().isNotEmpty) {
      return customPronouns!.trim();
    }
    return option;
  }

  Map<String, dynamic> toJson() => {
        'option': option,
        'customPronouns': customPronouns,
      };

  factory Pronouns.fromJson(Map<String, dynamic> json) => Pronouns(
        option: json['option'] as String? ?? '',
        customPronouns: json['customPronouns'] as String?,
      );

  Pronouns copyWith({
    String? option,
    String? customPronouns,
  }) {
    return Pronouns(
      option: option ?? this.option,
      customPronouns: customPronouns ?? this.customPronouns,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pronouns &&
          runtimeType == other.runtimeType &&
          option == other.option &&
          customPronouns == other.customPronouns;

  @override
  int get hashCode => option.hashCode ^ (customPronouns?.hashCode ?? 0);
}
