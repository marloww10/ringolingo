class MissaoModel {
  final int id;
  final String titulo;
  final String descricao;
  final String icone;
  final int xpRecompensa;
  final int meta;
  int progressoAtual;
  bool concluida;

  MissaoModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.xpRecompensa,
    required this.meta,
    this.progressoAtual = 0,
    this.concluida = false,
  });

  double get progresso => (progressoAtual / meta).clamp(0.0, 1.0);

  factory MissaoModel.fromJson(Map<String, dynamic> json) {
    // QuantidadeNecessaria não vem no response do controller,
    // então inferimos pelo nome da missão
    final nome = json['nome'] as String? ?? '';
    int meta = 5;
    if (nome == 'Tagarela') meta = 10;
    if (nome == 'Explorador') meta = 2;

    return MissaoModel(
      id: json['id'] as int,
      titulo: nome,
      descricao: json['descricao'] as String? ?? '',
      icone: json['emoji'] as String? ?? '⭐',
      xpRecompensa: json['xpRecompensa'] as int? ?? 0,
      meta: meta,
      progressoAtual: json['progresso'] as int? ?? 0,
      concluida: json['concluida'] as bool? ?? false,
    );
  }
}