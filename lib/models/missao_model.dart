enum TipoMissao {
  enviarMensagens,
  manterStreak,
  usarRinosDiferentes,
}

class MissaoModel {
  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final TipoMissao tipo;
  final int meta; // quantas vezes precisa fazer
  final int xpRecompensa;
  int progressoAtual;
  bool concluida;

  MissaoModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.tipo,
    required this.meta,
    required this.xpRecompensa,
    this.progressoAtual = 0,
    this.concluida = false,
  });

  // Porcentagem de progresso (0.0 a 1.0)
  double get progresso => (progressoAtual / meta).clamp(0.0, 1.0);

  // Avança o progresso e marca como concluída se atingir a meta
  void avancar([int quantidade = 1]) {
    if (concluida) return;
    progressoAtual = (progressoAtual + quantidade).clamp(0, meta);
    if (progressoAtual >= meta) {
      concluida = true;
    }
  }

  // Reseta para o próximo dia
  void resetar() {
    progressoAtual = 0;
    concluida = false;
  }

  // Missões padrão do dia
  static List<MissaoModel> missoesDiarias() {
    return [
      MissaoModel(
        id: 'enviar_5_mensagens',
        titulo: 'Conversador',
        descricao: 'Envie 5 mensagens para qualquer Ringo',
        icone: '💬',
        tipo: TipoMissao.enviarMensagens,
        meta: 5,
        xpRecompensa: 30,
      ),
      MissaoModel(
        id: 'enviar_10_mensagens',
        titulo: 'Tagarela',
        descricao: 'Envie 10 mensagens no total hoje',
        icone: '🗣️',
        tipo: TipoMissao.enviarMensagens,
        meta: 10,
        xpRecompensa: 60,
      ),
      MissaoModel(
        id: 'manter_streak',
        titulo: 'Consistente',
        descricao: 'Mantenha sua sequência de dias',
        icone: '🔥',
        tipo: TipoMissao.manterStreak,
        meta: 1,
        xpRecompensa: 20,
      ),
      MissaoModel(
        id: 'usar_2_ringos',
        titulo: 'Explorador',
        descricao: 'Converse com 2 Ringos diferentes hoje',
        icone: '🌟',
        tipo: TipoMissao.usarRinosDiferentes,
        meta: 2,
        xpRecompensa: 50,
      ),
    ];
  }
}