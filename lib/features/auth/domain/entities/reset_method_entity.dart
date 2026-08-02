enum ResetMethodType { email, twoFactor, googleAuth }

class ResetMethodEntity {
  const ResetMethodEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconColorHex,
    required this.iconKey,
  });

  final String id;
  final ResetMethodType type;
  final String title;
  final String description;
  final String iconColorHex;
  final String iconKey;
}
