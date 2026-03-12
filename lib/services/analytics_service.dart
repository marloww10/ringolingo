import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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
}