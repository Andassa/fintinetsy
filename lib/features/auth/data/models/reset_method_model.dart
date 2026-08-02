import '../../domain/entities/reset_method_entity.dart';

class ResetMethodModel {
  const ResetMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconColorHex,
    required this.iconKey,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String iconColorHex;
  final String iconKey;

  factory ResetMethodModel.fromJson(Map<String, dynamic> json) =>
      ResetMethodModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconColorHex: json['iconColorHex'] as String,
        iconKey: json['iconKey'] as String,
      );

  ResetMethodEntity toEntity() {
    final methodType = switch (type) {
      'twoFactor' => ResetMethodType.twoFactor,
      'googleAuth' => ResetMethodType.googleAuth,
      _ => ResetMethodType.email,
    };
    return ResetMethodEntity(
      id: id,
      type: methodType,
      title: title,
      description: description,
      iconColorHex: iconColorHex,
      iconKey: iconKey,
    );
  }
}
