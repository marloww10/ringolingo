class ConquistaModel {
  final int id;
  final String nome;
  final int xpGanho;
  final bool desbloqueada;
  final String descricao;
  final DateTime? dataConquista;

  ConquistaModel({
    required this.id,
    required this.nome,
    required this.xpGanho,
    required this.desbloqueada,
    required this.descricao,
    this.dataConquista,
  });

  factory ConquistaModel.fromJson(Map<String, dynamic> json) {
    return ConquistaModel(
      id: json['id'],
      nome: json['nome'],
      xpGanho: json['xpGanho'] ?? 0,
      desbloqueada: json['desbloqueada'] ?? false,
      descricao: json['descricao'] ?? '',
      dataConquista: json['dataConquista'] != null
          ? DateTime.parse(json['dataConquista'])
          : null,
    );
  }
}
