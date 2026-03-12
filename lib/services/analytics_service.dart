import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  // ── TELAS ──
  static Future logScreen(String screenName) async {
    await analytics.logScreenView(screenName: screenName);
  }

  // ── PERFIL ──
  static Future perfilConquistas() async {
    await analytics.logEvent(name: "perfil_conquistas_click");
  }

  static Future perfilIdiomas() async {
    await analytics.logEvent(name: "perfil_idiomas_click");
  }

  static Future perfilQuemSomos() async {
    await analytics.logEvent(name: "perfil_quem_somos_click");
  }

  static Future perfilLogout() async {
    await analytics.logEvent(name: "perfil_logout");
  }

  static Future perfilEditarFoto() async {
    await analytics.logEvent(name: "perfil_editar_foto");
  }

  // ── HOME ──
  static Future homeRingoAberto(String nomeRingo) async {
    await analytics.logEvent(
      name: "home_ringo_aberto",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future homeRingoBloqueadoClick(String nomeRingo) async {
    await analytics.logEvent(
      name: "home_ringo_bloqueado_click",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future homePerfilAberto() async {
    await analytics.logEvent(name: "home_perfil_aberto");
  }

  // ── CHAT ──
  static Future chatAberto(String nomeRingo) async {
    await analytics.logEvent(
      name: "chat_aberto",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future chatMensagemEnviada(String nomeRingo) async {
    await analytics.logEvent(
      name: "chat_mensagem_enviada",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future chatTraducaoAberta(String nomeRingo) async {
    await analytics.logEvent(
      name: "chat_traducao_aberta",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future chatDicaAberta(String nomeRingo) async {
    await analytics.logEvent(
      name: "chat_dica_aberta",
      parameters: {"ringo": nomeRingo},
    );
  }

  // ── ENGAJAMENTO ──
  static Future loginSucesso() async {
    await analytics.logEvent(name: "login_sucesso");
  }

  static Future cadastroSucesso() async {
    await analytics.logEvent(name: "cadastro_sucesso");
  }

  static Future nivelSubiu(int nivel) async {
    await analytics.logEvent(name: "nivel_subiu", parameters: {"nivel": nivel});
  }

  static Future streakAtingido(int dias) async {
    await analytics.logEvent(
      name: "streak_atingido",
      parameters: {"dias": dias},
    );
  }

  // ── ERROS ──
  static Future erroLogin(String motivo) async {
    await analytics.logEvent(
      name: "erro_login",
      parameters: {"motivo": motivo},
    );
  }

  static Future erroCadastro(String motivo) async {
    await analytics.logEvent(
      name: "erro_cadastro",
      parameters: {"motivo": motivo},
    );
  }

  static Future erroChat(String nomeRingo) async {
    await analytics.logEvent(
      name: "erro_chat",
      parameters: {"ringo": nomeRingo},
    );
  }

  static Future erroCarregarPersonas() async {
    await analytics.logEvent(name: "erro_carregar_personas");
  }
}
