/// Sexual Orientation domain model
class SexualOrientation {
  final String option;
  final String? customDescription;

  const SexualOrientation({
    required this.option,
    this.customDescription,
  });

  bool get isSelfDescribed => option == 'Prefer to self-describe';
  bool get isPreferNotToSay => option == 'Prefer not to say';

  String get displayValue {
    if (isSelfDescribed && customDescription != null && customDescription!.trim().isNotEmpty) {
      return customDescription!.trim();
    }
    return option;
  }

  Map<String, dynamic> toJson() => {
        'option': option,
        'customDescription': customDescription,
      };

  factory SexualOrientation.fromJson(Map<String, dynamic> json) => SexualOrientation(
        option: json['option'] as String? ?? '',
        customDescription: json['customDescription'] as String?,
      );

  SexualOrientation copyWith({
    String? option,
    String? customDescription,
  }) {
    return SexualOrientation(
      option: option ?? this.option,
      customDescription: customDescription ?? this.customDescription,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SexualOrientation &&
          runtimeType == other.runtimeType &&
          option == other.option &&
          customDescription == other.customDescription;

  @override
  int get hashCode => option.hashCode ^ (customDescription?.hashCode ?? 0);
}
