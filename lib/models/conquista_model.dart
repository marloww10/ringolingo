class ConquistaModel {
  final int id;
  final String nome;
  final int xpGanho;
  final bool desbloqueada;
  final DateTime? dataConquista;

  ConquistaModel({
    required this.id,
    required this.nome,
    required this.xpGanho,
    required this.desbloqueada,
    this.dataConquista,
  });

  factory ConquistaModel.fromJson(Map<String, dynamic> json) {
    return ConquistaModel(
      id: json['id'],
      nome: json['nome'],
      xpGanho: json['xpGanho'] ?? 0,
      desbloqueada: json['desbloqueada'] ?? false,
      dataConquista: json['dataConquista'] != null
          ? DateTime.parse(json['dataConquista'])
          : null,
    );
  }
}
