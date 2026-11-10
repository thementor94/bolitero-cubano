import json
import sqlite3
import os
import datetime

# 1. Definición completa de la Charada Tradicional Cubana (1 al 100)
# Con nombres oficiales primarios y sinónimos populares sincréticos
CHARADA_100 = [
    (1, "Caballo", "Sol, Candela, Revolución, Fidel, Dios, Pescado grande"),
    (2, "Mariposa", "Hombre, Dinero, Cafetera, Jinete"),
    (3, "Marinero", "Luna, Muerto, Taza, Ninfa, Viaje"),
    (4, "Gato", "Soldado, Llave, Espejo, Militar, Preso"),
    (5, "Monja", "Periódico, Mar, Navaja, Candela"),
    (6, "Jicotea", "Carta, Teléfono, Botella, Luna"),
    (7, "Caracol", "Sueño, Mierda, Pintor, Gallina"),
    (8, "Muerto", "León, Calavera, Dinero, Vaso"),
    (9, "Elefante", "Entierro, Lengua, Lira, Foso"),
    (10, "Pescado grande", "Cazador, Desgracia, Malla, Red"),
    (11, "Gallo", "Lluvia, Barril, Fábrica, Caballo"),
    (12, "Mujer santa", "Viaje, Cometa, Niebla, Río"),
    (13, "Pavo real", "Niño, Fruta, Cienpiés, Elefante"),
    (14, "Gato tigre", "Cementerio, Sartén, Enamorado"),
    (15, "Perro", "Visita, Muerto, Celo, Cuchillo, Malvado"),
    (16, "Toro", "Virgen, Carta, Pecho, Ternero"),
    (17, "Luna", "San Lázaro, Armas, Médico, Camisón"),
    (18, "Pescadito", "Iglesia, Barco, Sirena, Palma"),
    (19, "Lombriz", "Mesa, Campesino, Fusil, Bandera"),
    (20, "Gato fino", "Cañón, Orina, Libro, Tiburón"),
    (21, "Majá", "Serpiente, Culebra, Dinero, Cigarro"),
    (22, "Sapo", "Estrella, Lirio, Chimenea, Sol"),
    (23, "Barco", "Vapor, Escalera, Águila, Monte"),
    (24, "Paloma", "Música, Viento, Carpintero, Reloj"),
    (25, "Piedra fina", "Casa, Sol, Doncella, Granada"),
    (26, "Anguila", "Médico, Calle, Nube, Brillante"),
    (27, "Avispa", "Canario, Campana, Madre, Iglesia"),
    (28, "Chivo", "Político, Tabaco, Disparo, Uva"),
    (29, "Ratón", "Nube, Venado, Águila, Melón"),
    (30, "Camarón", "Arcoíris, Cangrejo, Monja, Alfiler"),
    (31, "Venado", "Sorpresa, Escuela, Soldado, Carta"),
    (32, "Cochino", "Enemigo, Mula, Demonio, Reloj"),
    (33, "Tiñosa", "Muerte, Baraja, Huracán, Luto"),
    (34, "Mono", "Negro, Familia, Sombrero, Lotería"),
    (35, "Araña", "Bombillo, Herradura, Marinero, Zapato"),
    (36, "Colibrí", "Pajarito, Brujo, Cueva, Flecha"),
    (37, "Brujería", "Gallina, Hormiga, Piedra, Policía"),
    (38, "Macao", "Guardián, Dinero, Reloj, Carretilla"),
    (39, "Conejo", "Rayo, Baile, Tinta, Serpiente"),
    (40, "Cura", "Santo, Campanario, Sangre, Barba"),
    (41, "Lagartija", "Prisión, Pato, Relámpago, Muerte"),
    (42, "Pato", "País, Abogado, Cama, Joya"),
    (43, "Alacrán", "Amigo, Puñal, Ventana, Espejo"),
    (44, "Año malo", "Tempestad, Desgracia, Fruta, Hierro"),
    (45, "Tiburón", "Presidente, Policía, Navaja, Zapato"),
    (46, "Guajiro", "Humo, Sombrero, Salto, Palma"),
    (47, "Pájaro", "Mundo, Rosa, Escopeta, Volcán"),
    (48, "Cucaracha", "Accidente, Miedo, Agua, Reloj"),
    (49, "Borracho", "Pluma, Percha, Llave, Látigo"),
    (50, "Policía", "Flor, Agua, Cautiverio, Candado"),
    (51, "Soldado", "Oggún, Hierro, Sereno, Sed"),
    (52, "Bicicleta", "Coche, Abogado, Rueda, Libreta"),
    (53, "Luz", "Prenda, Trono, Diamante, Tragedia"),
    (54, "Flores", "Cañón, Espada, Sueño, Tambor"),
    (55, "Cangrejo", "Isla, Espejo, Fuego, Policía"),
    (56, "Reina", "Meretriz, Mariposa, Camisa, Cara"),
    (57, "Cama", "Telegrama, Noche, Puerta, Novia"),
    (58, "Adulterio", "Retrato, Cruz, Cangrejo, Vaso"),
    (59, "Loco", "Fonógrafo, Calavera, Moneda, Culebra"),
    (60, "Payaso", "Sol, Comiquita, Huevo, Tambor"),
    (61, "Cañón", "Piedra, Escopeta, Soldado, Tijera"),
    (62, "Matrimonio", "Nieve, Lámpara, Carretera, Toro"),
    (63, "Asesino", "Bandido, Escalera, Cuerno, Policía"),
    (64, "Muerto grande", "Falso, Reloj, Campana, Tiro"),
    (65, "Comida", "Oshún, Brujo, Cárcel, Cazuela"),
    (66, "Diablo", "Carnaval, Máscara, Pozo, Carbón"),
    (67, "Puñalada", "Relámpago, Autoridad, Herida, Reloj"),
    (68, "Grande", "Templo, Globo, Circo, Palma"),
    (69, "Pozo", "Fango, Barco, Reloj, Río"),
    (70, "Teléfono", "Tiro, Barril, Sapo, Arco"),
    (71, "Fusil", "Perro, Sombrero, Soldado, Baile"),
    (72, "Buey", "Collar, Ferrocarril, Jarro, Látigo"),
    (73, "Navaja", "Corte, Manzana, Parque, Bandera"),
    (74, "Papalote", "Militar, Serpiente, Ruina, Corona"),
    (75, "Cine", "Guitarra, Pito, Novio, Estrella"),
    (76, "Humo", "Hierro, Bomba, Pájaro, Reloj"),
    (77, "Banderas", "Yúa, Muletas, Guerra, Trono"),
    (78, "Obispo", "Sarcófago, Ataúd, Luna, Viento"),
    (79, "Tren", "Coche, Abogado, Lagarto, Botella"),
    (80, "Vieja", "Buena suerte, Trompo, Cama, Sol"),
    (81, "Teatro", "Actor, Ingeniero, Barco, Reloj"),
    (82, "Madre", "León, Bautizo, Tragedia, Flor"),
    (83, "Tragedia", "Limosnero, Madera, Bastón, Muerte"),
    (84, "Sangre", "Ciego, Banquete, Hacha, Oro"),
    (85, "Reloj", "Tiempo, Espejo, Águila, Policía"),
    (86, "Convento", "Tijeras, Monja, Fuego, Carretilla"),
    (87, "Plátano", "Fuego, Toro, Espada, Cueva"),
    (88, "Hojas", "Aduana, Trompeta, Muerte, Vidrio"),
    (89, "Cometa", "Lotería, Melón, Anciano, Tambor"),
    (90, "Viejo", "Esclavo, Dinero, Cruz, Espejo"),
    (91, "Tranvía", "Pájaro, Limosna, Bolso, Carta"),
    (92, "Avión", "Globo, Estrella, Cuba, Nube"),
    (93, "Sortija", "Revolución, General, Joya, Anillo"),
    (94, "Machete", "Mariposa, Habana, Cuchillo, Flores"),
    (95, "Guerra", "Perro grande, Espada, Dragón, Fuego"),
    (96, "Desafío", "Zapato, Médico, Pavo, Bandera"),
    (97, "Grillo", "Limosnero, Manta, Viejo, Miedo"),
    (98, "Entierro", "Traición, Santo, Piano, Muerto"),
    (99, "Serpiente", "Carbonero, Pozo, Brujo, Cueva"),
    (100, "Dios", "Inodoro, Escoba, Muerte, Fin")
]

# 2. Histórico inicial verificado de sorteos (Florida, Georgia, NY)
# Formato adaptado a la regla consensuada:
# Pick 3: "4-1-5" -> Centena: "415", Fijo: "15"
# Pick 4: "3-1-0-8" -> Corrido1: "31", Corrido2: "08"
INITIAL_DRAWS = [
    {
        "id": "FL-EVE-20261109",
        "lottery": "florida",
        "period": "evening",
        "draw_date": "2026-11-09",
        "draw_time": "21:45",
        "pick3_raw": "4-1-5",
        "pick4_raw": "3-1-0-8",
        "fijo": "15",
        "centena": "415",
        "corrido1": "31",
        "corrido2": "08",
        "status": "official"
    },
    {
        "id": "FL-MID-20261109",
        "lottery": "florida",
        "period": "midday",
        "draw_date": "2026-11-09",
        "draw_time": "13:30",
        "pick3_raw": "9-2-1",
        "pick4_raw": "1-1-2-4",
        "fijo": "21",
        "centena": "921",
        "corrido1": "11",
        "corrido2": "24",
        "status": "official"
    },
    {
        "id": "FL-EVE-20261108",
        "lottery": "florida",
        "period": "evening",
        "draw_date": "2026-11-08",
        "draw_time": "21:45",
        "pick3_raw": "2-4-6",
        "pick4_raw": "7-0-1-3",
        "fijo": "46",
        "centena": "246",
        "corrido1": "70",
        "corrido2": "13",
        "status": "official"
    },
    {
        "id": "FL-MID-20261108",
        "lottery": "florida",
        "period": "midday",
        "draw_date": "2026-11-08",
        "draw_time": "13:30",
        "pick3_raw": "5-9-2",
        "pick4_raw": "3-7-6-1",
        "fijo": "92",
        "centena": "592",
        "corrido1": "37",
        "corrido2": "61",
        "status": "official"
    },
    {
        "id": "FL-EVE-20261107",
        "lottery": "florida",
        "period": "evening",
        "draw_date": "2026-11-07",
        "draw_time": "21:45",
        "pick3_raw": "8-0-4",
        "pick4_raw": "5-5-9-8",
        "fijo": "04",
        "centena": "804",
        "corrido1": "55",
        "corrido2": "98",
        "status": "official"
    },
    {
        "id": "GA-EVE-20261109",
        "lottery": "georgia",
        "period": "evening",
        "draw_date": "2026-11-09",
        "draw_time": "19:00",
        "pick3_raw": "1-6-7",
        "pick4_raw": "4-0-5-2",
        "fijo": "67",
        "centena": "167",
        "corrido1": "40",
        "corrido2": "52",
        "status": "official"
    },
    {
        "id": "GA-MID-20261109",
        "lottery": "georgia",
        "period": "midday",
        "draw_date": "2026-11-09",
        "draw_time": "12:29",
        "pick3_raw": "4-0-3",
        "pick4_raw": "1-8-7-6",
        "fijo": "03",
        "centena": "403",
        "corrido1": "18",
        "corrido2": "76",
        "status": "official"
    },
    {
        "id": "NY-EVE-20261109",
        "lottery": "new_york",
        "period": "evening",
        "draw_date": "2026-11-09",
        "draw_time": "22:30",
        "pick3_raw": "3-8-8",
        "pick4_raw": "0-5-2-9",
        "fijo": "88",
        "centena": "388",
        "corrido1": "05",
        "corrido2": "29",
        "status": "official"
    }
]

def generate_sqlite_seed(db_path):
    if os.path.exists(db_path):
        os.remove(db_path)
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 1. Tabla de Charada
    cursor.execute("""
    CREATE TABLE charada_entries (
        number INTEGER PRIMARY KEY,
        primary_name TEXT NOT NULL,
        category TEXT DEFAULT 'clasica',
        synonyms TEXT NOT NULL,
        description TEXT
    );
    """)
    
    for num, name, syn in CHARADA_100:
        cursor.execute("""
        INSERT INTO charada_entries (number, primary_name, category, synonyms, description)
        VALUES (?, ?, 'clasica', ?, '')
        """, (num, name, syn))
        
    # 2. Tabla de Sorteos
    cursor.execute("""
    CREATE TABLE local_draws (
        id TEXT PRIMARY KEY,
        lottery TEXT NOT NULL,
        period TEXT NOT NULL,
        draw_date TEXT NOT NULL,
        draw_time TEXT,
        pick3_raw TEXT NOT NULL,
        pick4_raw TEXT,
        fijo TEXT NOT NULL,
        centena TEXT NOT NULL,
        corrido1 TEXT,
        corrido2 TEXT,
        status TEXT DEFAULT 'official',
        created_at INTEGER NOT NULL
    );
    """)
    
    now_ms = int(datetime.datetime.now().timestamp() * 1000)
    for d in INITIAL_DRAWS:
        cursor.execute("""
        INSERT INTO local_draws (id, lottery, period, draw_date, draw_time, pick3_raw, pick4_raw, fijo, centena, corrido1, corrido2, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (d["id"], d["lottery"], d["period"], d["draw_date"], d["draw_time"], d["pick3_raw"], d["pick4_raw"], d["fijo"], d["centena"], d["corrido1"], d["corrido2"], d["status"], now_ms))
        
    # 3. Tabla de Mi Laboratorio
    cursor.execute("""
    CREATE TABLE lab_plays (
        id TEXT PRIMARY KEY,
        draw_date TEXT NOT NULL,
        lottery TEXT NOT NULL,
        period TEXT NOT NULL,
        play_type TEXT NOT NULL,
        numbers TEXT NOT NULL,
        virtual_points REAL DEFAULT 10.0,
        status TEXT DEFAULT 'pending',
        payout_multiplier REAL DEFAULT 0.0,
        total_payout REAL DEFAULT 0.0,
        created_at INTEGER NOT NULL,
        settled_at INTEGER
    );
    """)

    # 4. Tabla de encuestas anónimas locales
    cursor.execute("""
    CREATE TABLE local_votes (
        draw_target_id TEXT PRIMARY KEY,
        voted_number TEXT NOT NULL,
        voted_at INTEGER NOT NULL,
        synced_with_cloud INTEGER DEFAULT 0
    );
    """)

    conn.commit()
    conn.close()
    print(f"Base de datos SQLite generada exitosamente en: {db_path}")

def generate_json_seed(json_path):
    data = []
    for num, name, syn in CHARADA_100:
        syn_list = [s.strip() for s in syn.split(",")]
        data.append({
            "number": num,
            "primary_name": name,
            "category": "clasica",
            "synonyms": syn_list
        })
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"JSON de Charada generado exitosamente en: {json_path}")

def generate_latest_cdn(public_json_path):
    os.makedirs(os.path.dirname(public_json_path), exist_ok=True)
    payload = {
        "version": 1,
        "updated_at": "2026-11-09T21:48:00Z",
        "draws": INITIAL_DRAWS
    }
    with open(public_json_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    print(f"latest.json para CDN generado en: {public_json_path}")

if __name__ == "__main__":
    os.makedirs("assets/seed", exist_ok=True)
    os.makedirs("public", exist_ok=True)
    generate_sqlite_seed("assets/seed/bolitero_seed.db")
    generate_json_seed("assets/seed/charada_seed.json")
    generate_latest_cdn("public/latest.json")
