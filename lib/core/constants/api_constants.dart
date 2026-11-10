abstract final class ApiConstants {
  // Endpoints de alta disponibilidad servidos a través de CDN global (GitHub Pages / Cloudflare)
  static const String latestCdnUrl = "https://thementor94.github.io/bolitero-cubano/latest.json";
  static const String historyCdnUrl = "https://thementor94.github.io/bolitero-cubano/history.json";
  static const String pollCdnUrl = "https://thementor94.github.io/bolitero-cubano/daily_poll.json";
  
  // Timeout adaptado a la latencia real y condiciones de redes ETECSA (12 segundos)
  static const Duration networkTimeout = Duration(seconds: 12);
}
