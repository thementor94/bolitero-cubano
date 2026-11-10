import os
import json
import requests
import datetime
import time
import re
from bs4 import BeautifulSoup

# URLs oficiales y secundarias
FL_PICK3_URL = "https://www.flalottery.com/exptkt/pick3.html"
FL_PICK4_URL = "https://www.flalottery.com/exptkt/pick4.html"
NY_OPEN_DATA_URL = "https://data.ny.gov/resource/5xaw-6ayf.json?$limit=10&$order=draw_date%20DESC"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language": "es-ES,es;q=0.9,en-US;q=0.8,en;q=0.7",
    "Cache-Control": "no-cache",
}

def parse_digits_from_text(text):
    """Extrae todos los dígitos individuales de un texto."""
    return re.findall(r'\b\d\b', text)

def fetch_florida_html(session, url):
    """Descarga HTML de Florida Lottery con reintentos."""
    for attempt in range(3):
        try:
            resp = session.get(url, headers=HEADERS, timeout=15)
            if resp.status_code == 200 and len(resp.text) > 500:
                return resp.text
        except Exception as e:
            print(f"[Scraper] Intento {attempt+1} fallido para {url}: {e}")
        time.sleep(2)
    return None

def parse_florida_table(html):
    """
    Parsea las tablas históricas de Florida Lottery (pick3.html / pick4.html).
    Devuelve lista de diccionarios: {'date': 'YYYY-MM-DD', 'period': 'midday'/'evening', 'digits': [...]}
    """
    results = []
    if not html:
        return results
    
    soup = BeautifulSoup(html, 'html.parser')
    # Buscar filas con fechas y números
    text = soup.get_text()
    # Formato habitual en el pre/tabla: MM/DD/YY o similar con dígitos
    lines = text.split('\n')
    date_regex = re.compile(r'(\d{1,2}/\d{1,2}/\d{2,4})')
    
    for line in lines:
        match = date_regex.search(line)
        if match:
            date_raw = match.group(1)
            # Extraer números tras la fecha
            parts = line[match.end():].strip().split()
            digits = []
            for p in parts:
                cleaned = re.sub(r'\D', '', p)
                if cleaned:
                    digits.extend(list(cleaned))
            
            # Periodo según hora o posición si está indicado
            period = "evening" if "Eve" in line or "EVE" in line else "midday" if "Mid" in line or "MID" in line else None
            
            # Normalizar fecha YYYY-MM-DD
            try:
                date_obj = datetime.datetime.strptime(date_raw, "%m/%d/%y") if len(date_raw.split('/')[-1]) == 2 else datetime.datetime.strptime(date_raw, "%m/%d/%Y")
                date_iso = date_obj.strftime("%Y-%m-%d")
                if digits:
                    results.append({
                        "date": date_iso,
                        "period": period or "evening",
                        "digits": digits
                    })
            except Exception:
                pass
    return results

def scrape_florida():
    """Extrae resultados de la Lotería de Florida (Pick 3 y Pick 4)."""
    print("[Ingesta] Iniciando sondeo de Florida Lottery...")
    session = requests.Session()
    
    p3_html = fetch_florida_html(session, FL_PICK3_URL)
    p4_html = fetch_florida_html(session, FL_PICK4_URL)
    
    p3_data = parse_florida_table(p3_html)
    p4_data = parse_florida_table(p4_html)
    
    extracted_draws = []
    
    # Cruzar Pick 3 con Pick 4 por (fecha, periodo)
    p4_map = {(x["date"], x["period"]): x["digits"] for x in p4_data}
    
    for p3 in p3_data[:6]: # Últimos tiros disponibles
        date_str = p3["date"]
        period = p3["period"]
        p3_digits = p3["digits"]
        
        if len(p3_digits) >= 3:
            d1, d2, d3 = p3_digits[0], p3_digits[1], p3_digits[2]
            p3_raw = f"{d1}-{d2}-{d3}"
            centena = f"{d1}{d2}{d3}"
            fijo = f"{d2}{d3}"
            
            p4_digits = p4_map.get((date_str, period), [])
            if len(p4_digits) >= 4:
                c1 = f"{p4_digits[0]}{p4_digits[1]}"
                c2 = f"{p4_digits[2]}{p4_digits[3]}"
                p4_raw = f"{p4_digits[0]}-{p4_digits[1]}-{p4_digits[2]}-{p4_digits[3]}"
            else:
                c1, c2, p4_raw = None, None, None
                
            compact_date = date_str.replace("-", "")
            id_prefix = "FL-EVE" if period == "evening" else "FL-MID"
            draw_time = "21:45" if period == "evening" else "13:30"
            
            extracted_draws.append({
                "id": f"{id_prefix}-{compact_date}",
                "lottery": "florida",
                "period": period,
                "draw_date": date_str,
                "draw_time": draw_time,
                "pick3_raw": p3_raw,
                "pick4_raw": p4_raw,
                "fijo": fijo,
                "centena": centena,
                "corrido1": c1,
                "corrido2": c2,
                "status": "official",
                "created_at": int(datetime.datetime.utcnow().timestamp() * 1000)
            })
            
    return extracted_draws

def update_cdn(new_draws):
    """Actualiza latest.json y history.json atómicamente."""
    if not new_draws:
        print("[CDN] No hay nuevos sorteos para actualizar.")
        return
        
    latest_path = "public/latest.json"
    history_path = "public/history.json"
    
    # Cargar existente
    existing_draws = {}
    if os.path.exists(history_path):
        try:
            with open(history_path, "r", encoding="utf-8") as f:
                h_data = json.load(f)
                for d in h_data.get("draws", []):
                    existing_draws[d["id"]] = d
        except Exception as e:
            print(f"[CDN] Error leyendo history.json existente: {e}")
            
    # Mezclar nuevos sorteos
    for nd in new_draws:
        existing_draws[nd["id"]] = nd
        
    all_draws = list(existing_draws.values())
    all_draws.sort(key=lambda x: (x.get("draw_date", ""), x.get("draw_time", "")), reverse=True)
    
    # Guardar history.json
    h_payload = {
        "version": 1,
        "updated_at": datetime.datetime.utcnow().isoformat() + "Z",
        "total_draws": len(all_draws),
        "draws": all_draws
    }
    with open(history_path, "w", encoding="utf-8") as f:
        json.dump(h_payload, f, ensure_ascii=False, indent=2)
    print(f"[CDN] history.json actualizado con {len(all_draws)} sorteos.")
    
    # Guardar latest.json (últimos 15 sorteos)
    l_payload = {
        "version": 1,
        "updated_at": datetime.datetime.utcnow().isoformat() + "Z",
        "draws": all_draws[:15]
    }
    with open(latest_path, "w", encoding="utf-8") as f:
        json.dump(l_payload, f, ensure_ascii=False, indent=2)
    print(f"[CDN] latest.json actualizado con {len(all_draws[:15])} sorteos.")

def run_pipeline():
    print(f"[Ingesta] Ejecutando pipeline en {datetime.datetime.utcnow().isoformat()}Z")
    fl_draws = scrape_florida()
    if fl_draws:
        print(f"[Ingesta] {len(fl_draws)} sorteos obtenidos de Florida.")
        update_cdn(fl_draws)
    else:
        print("[Ingesta] Florida web no disponible en este momento. Preservando estado existente.")

if __name__ == "__main__":
    run_pipeline()
