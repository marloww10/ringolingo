class RingoModel {
  final int id;
  final String nome;
  final String imagemUrl;
  final int nivelNecessario;

  RingoModel({
    required this.id,
    required this.nome,
    required this.imagemUrl,
    required this.nivelNecessario,
  });

  factory RingoModel.fromJson(Map<String, dynamic> json) {
    return RingoModel(
      id: json['id'],
      nome: json['nome'],
      imagemUrl: json['imagemUrl'] ?? '',
      nivelNecessario: json['nivelNecessario'] ?? 1,
    );
  }
}
