abstract final class ApiConstants {
  // Endpoint de alta disponibilidad servido a través de CDN global (Cloudflare / GitHub Pages)
  static const String latestCdnUrl = "https://raw.githubusercontent.com/r0ku/bolitero_cubano/main/public/latest.json";
  
  // Timeout estricto para evitar bloqueos en conexiones lentas de ETECSA
  static const Duration networkTimeout = Duration(seconds: 5);
}
