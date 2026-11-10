import json
import sqlite3
import os
import datetime
import random

# Definición canónica de la Charada Cubana Tradicional (1 al 100)
# Incluye Deidad sincrética / Orisha y los números acompañantes (que jalan) tradicionales
CHARADA_100_FULL = [
    (1, "Caballo", "clasica", "Sol, Candela, Revolución, Fidel, Pescado grande", "Changó / Santa Bárbara", "24, 52, 79", "Representa la fuerza, el sol naciente y el movimiento imponente."),
    (2, "Mariposa", "clasica", "Hombre, Dinero, Cafetera, Jinete, Papalote", "Ochún / Caridad del Cobre", "16, 25, 94", "Símbolo de transformación, elegancia y fortuna rápida."),
    (3, "Marinero", "clasica", "Luna, Muerto, Taza, Ninfa, Viaje, Barco", "Yemayá / Virgen de Regla", "21, 54, 73", "El hombre de mar, vinculado a las mareas y a Eleguá abrecaminos."),
    (4, "Gato", "clasica", "Soldado, Llave, Espejo, Militar, Preso", "Ogún / San Pedro", "24, 40, 84", "Sigilo, agilidad y destreza en momentos difíciles."),
    (5, "Monja", "clasica", "Periódico, Mar, Navaja, Candela, Carta", "Obatalá / Virgen de las Mercedes", "15, 25, 55", "Pureza, devoción y noticias que llegan por escrito."),
    (6, "Jicotea", "clasica", "Carta, Teléfono, Botella, Luna, Mazo", "Changó / Santa Bárbara", "36, 42, 88", "Sabiduría antigua, paciencia y protección acorazada."),
    (7, "Caracol", "clasica", "Sueño, Pintor, Gallina, Mierda, Llave", "Yemayá / Virgen de Regla", "14, 49, 70", "El caracol del adivino, comunicación con los orishas."),
    (8, "Muerto", "clasica", "León, Calavera, Dinero, Vaso, Cuadro", "Oyá / Virgen de la Candelaria", "16, 24, 64", "Espíritus protectores y revelaciones en sueños."),
    (9, "Elefante", "clasica", "Entierro, Lengua, Lira, Foso, Tambor", "Obatalá / Virgen de las Mercedes", "19, 45, 90", "Fuerza imperturbable, longevidad y memoria."),
    (10, "Pescado grande", "clasica", "Cazador, Desgracia, Malla, Red, Barco", "Yemayá / Virgen de Regla", "18, 23, 70", "Abundancia marina y misterio de las profundidades."),
    (11, "Gallo", "clasica", "Lluvia, Barril, Fábrica, Caballo, Despertar", "Changó / Santa Bárbara", "1, 28, 77", "Vigilancia, valentía y anuncio de la luz."),
    (12, "Mujer santa", "clasica", "Viaje, Cometa, Niebla, Río, Corona", "Ochún / Caridad del Cobre", "25, 55, 65", "Bendición celestial y protección materna."),
    (13, "Pavo real", "clasica", "Niño, Fruta, Cienpiés, Elefante, Espejo", "Ochún / Caridad del Cobre", "2, 38, 75", "Orgullo, esplendor y belleza radiante."),
    (14, "Gato tigre", "clasica", "Cementerio, Sartén, Enamorado, Fuego", "Oyá / Virgen de la Candelaria", "4, 43, 78", "Astucia salvaje y dominio del territorio nocturno."),
    (15, "Perro", "clasica", "Visita, Muerto, Celo, Cuchillo, Malvado", "Babalú Ayé / San Lázaro", "40, 71, 95", "Lealtad incondicional, visitas inesperadas y aviso."),
    (16, "Toro", "clasica", "Virgen, Carta, Pecho, Ternero, Candela", "Changó / Santa Bárbara", "2, 62, 87", "Poder telúrico, empuje y resistencia."),
    (17, "Luna", "clasica", "San Lázaro, Armas, Médico, Camisón", "Babalú Ayé / San Lázaro", "3, 33, 77", "Intuición, misterio y curación espiritual."),
    (18, "Pescadito", "clasica", "Iglesia, Barco, Sirena, Palma, Río", "Yemayá / Virgen de Regla", "10, 30, 81", "Pequeños golpes de suerte que alimentan el día."),
    (19, "Lombriz", "clasica", "Mesa, Campesino, Fusil, Bandera, Raíz", "Ochosi / San Norberto", "9, 46, 91", "Humildad, trabajo subterráneo y constancia."),
    (20, "Gato fino", "clasica", "Cañón, Orina, Libro, Tiburón, Seda", "Ochún / Caridad del Cobre", "4, 14, 56", "Distinción, elegancia y caricias traicioneras."),
    (21, "Majá", "clasica", "Serpiente, Culebra, Dinero, Cigarro", "Eleguá / San Antonio", "3, 54, 99", "Sabiduría oculta y astucia en el dinero."),
    (22, "Sapo", "clasica", "Estrella, Lirio, Chimenea, Sol, Charco", "Babalú Ayé / San Lázaro", "6, 41, 70", "Transformación mágica y augurio de lluvias."),
    (23, "Barco", "clasica", "Vapor, Escalera, Águila, Monte, Ancla", "Yemayá / Virgen de Regla", "3, 10, 81", "Emprendimientos, travesías y puertos seguros."),
    (24, "Paloma", "clasica", "Música, Viento, Carpintero, Reloj, Paz", "Obatalá / Virgen de las Mercedes", "1, 4, 80", "Mensaje divino, paz espiritual y serenidad."),
    (25, "Piedra fina", "clasica", "Casa, Sol, Doncella, Granada, Joya", "Ochún / Caridad del Cobre", "2, 12, 53", "Valor incalculable y tesoros protegidos."),
    (26, "Anguila", "clasica", "Médico, Calle, Nube, Brillante, Escape", "Yemayá / Virgen de Regla", "18, 45, 92", "Situaciones escurridizas donde reina la astucia."),
    (27, "Avispa", "clasica", "Canario, Campana, Madre, Iglesia, Aguijón", "Oyá / Virgen de la Candelaria", "7, 37, 82", "Advertencia de disgustos y picaduras de celos."),
    (28, "Chivo", "clasica", "Político, Tabaco, Disparo, Uva, Barba", "Eleguá / San Antonio", "4, 11, 72", "Testarudez, ofrenda y debates acalorados."),
    (29, "Ratón", "clasica", "Nube, Venado, Águila, Melón, Queso", "Eleguá / San Antonio", "31, 35, 97", "Pequeños hurtos y movimientos en la penumbra."),
    (30, "Camarón", "clasica", "Arcoíris, Cangrejo, Monja, Alfiler, Marea", "Yemayá / Virgen de Regla", "5, 18, 55", "Cuidado con dormirse en la corriente."),
    (31, "Venado", "clasica", "Sorpresa, Escuela, Soldado, Carta, Bosque", "Ochosi / San Norberto", "29, 39, 96", "Velocidad para escapar de trampas y peligros."),
    (32, "Cochino", "clasica", "Enemigo, Mula, Demonio, Reloj, Grasa", "Ogún / San Pedro", "48, 66, 83", "Abundancia material pero peligro de traición."),
    (33, "Tiñosa", "clasica", "Muerte, Baraja, Huracán, Luto, Ceniza", "Oyá / Virgen de la Candelaria", "8, 17, 98", "Círculos sobre lo que fenece; renovación kármica."),
    (34, "Mono", "clasica", "Negro, Familia, Sombrero, Lotería, Burla", "Eleguá / San Antonio", "42, 60, 93", "Imitación, travesuras y golpes de suerte."),
    (35, "Araña", "clasica", "Bombillo, Herradura, Marinero, Zapato, Red", "Oyá / Virgen de la Candelaria", "3, 29, 43", "Tejedora de destinos y paciencia matemática."),
    (36, "Colibrí", "clasica", "Pajarito, Brujo, Cueva, Flecha, Miel", "Ochún / Caridad del Cobre", "6, 47, 85", "Alegría fugaz, velocidad y encanto."),
    (37, "Brujería", "clasica", "Gallina, Hormiga, Piedra, Policía, Hechizo", "Eleguá / San Antonio", "7, 27, 99", "Fuerzas ocultas en acción y advertencia espiritual."),
    (38, "Macao", "clasica", "Guardián, Dinero, Reloj, Carretilla, Concha", "Yemayá / Virgen de Regla", "13, 50, 78", "Resguardo seguro y protección económica."),
    (39, "Conejo", "clasica", "Rayo, Baile, Tinta, Serpiente, Huerto", "Ochosi / San Norberto", "7, 31, 77", "Fertilidad, saltos audaces y agilidad mental."),
    (40, "Cura", "clasica", "Santo, Campanario, Sangre, Barba, Misa", "Obatalá / Virgen de las Mercedes", "4, 15, 84", "Consejo sabio, bendición y reflexión moral."),
    (41, "Lagartija", "clasica", "Prisión, Pato, Relámpago, Muerte, Muro", "Ochosi / San Norberto", "22, 67, 79", "Adaptabilidad a los muros y calor del sol."),
    (42, "Pato", "clasica", "País, Abogado, Cama, Joya, Laguna", "Yemayá / Virgen de Regla", "6, 34, 88", "Tranquilidad en la superficie con nado firme."),
    (43, "Alacrán", "clasica", "Amigo, Puñal, Ventana, Espejo, Veneno", "Ogún / San Pedro", "14, 35, 73", "Cuidado con falsas amistades que portan puñal."),
    (44, "Año malo", "clasica", "Tempestad, Desgracia, Fruta, Hierro, Crisis", "Oyá / Virgen de la Candelaria", "58, 83, 98", "Pruebas de carácter y resistencia en la tormenta."),
    (45, "Tiburón", "clasica", "Presidente, Policía, Navaja, Zapato, Mandíbula", "Yemayá / Virgen de Regla", "9, 26, 90", "Fuerza implacable en negocios y justicia."),
    (46, "Guajiro", "clasica", "Humo, Sombrero, Salto, Palma, Tabacal", "Ochosi / San Norberto", "19, 72, 87", "Trabajador noble de la tierra con sabiduría campechana."),
    (47, "Pájaro", "clasica", "Mundo, Rosa, Escopeta, Volcán, Nido", "Obatalá / Virgen de las Mercedes", "36, 54, 91", "Libertad, vuelos elevados y nuevos horizontes."),
    (48, "Cucaracha", "clasica", "Accidente, Miedo, Agua, Reloj, Grieta", "Oyá / Virgen de la Candelaria", "32, 57, 85", "Supervivencia tenaz ante la adversidad."),
    (49, "Borracho", "clasica", "Pluma, Percha, Llave, Látigo, Botella", "Osain / San Silvestre", "7, 65, 89", "Desinhibición, verdades cantadas y extravío."),
    (50, "Policía", "clasica", "Flor, Agua, Cautiverio, Candado, Placa", "Ochosi / San Norberto", "38, 63, 85", "Autoridad, orden y vigilancia de caminos."),
    (51, "Soldado", "clasica", "Oggún, Hierro, Sereno, Sed, Escudo", "Ogún / San Pedro", "4, 71, 95", "Disciplina, batalla ganada y protección física."),
    (52, "Bicicleta", "clasica", "Coche, Abogado, Rueda, Libreta, Equilibrio", "Eleguá / San Antonio", "1, 62, 79", "Avance mediante el esfuerzo propio constante."),
    (53, "Luz", "clasica", "Prenda, Trono, Diamante, Tragedia, Faro", "Obatalá / Virgen de las Mercedes", "25, 59, 84", "Claridad mental que disipa las tinieblas."),
    (54, "Flores", "clasica", "Cañón, Espada, Sueño, Tambor, Jardín", "Ochún / Caridad del Cobre", "3, 21, 73", "Ofrenda de amor, fragancia y reconciliación."),
    (55, "Cangrejo", "clasica", "Isla, Espejo, Fuego, Policía, Muelle", "Yemayá / Virgen de Regla", "5, 12, 30", "Pasos laterales necesarios antes del gran avance."),
    (56, "Reina", "clasica", "Meretriz, Mariposa, Camisa, Cara, Corona", "Ochún / Caridad del Cobre", "20, 68, 82", "Elegancia suprema y magnetismo irresistible."),
    (57, "Cama", "clasica", "Telegrama, Noche, Puerta, Novia, Reposo", "Yemayá / Virgen de Regla", "48, 80, 97", "Descanso reparador o indisposición pasajera."),
    (58, "Adulterio", "clasica", "Retrato, Cruz, Cangrejo, Vaso, Secreto", "Changó / Santa Bárbara", "44, 75, 94", "Doble juego que exige prudencia absoluta."),
    (59, "Loco", "clasica", "Fonógrafo, Calavera, Moneda, Culebra, Risa", "Eleguá / San Antonio", "53, 66, 89", "Ideas fuera de lo común que traen éxito sorpresivo."),
    (60, "Payaso", "clasica", "Sol, Comiquita, Huevo, Tambor, Sonrisa", "Eleguá / San Antonio", "34, 75, 92", "Alegría compartida que maquilla las penas."),
    (61, "Cañón", "clasica", "Piedra, Escopeta, Soldado, Tijera, Pólvora", "Changó / Santa Bárbara", "16, 51, 87", "Determinación fulminante en el momento decisivo."),
    (62, "Matrimonio", "clasica", "Nieve, Lámpara, Carretera, Toro, Alianza", "Ochún / Caridad del Cobre", "16, 52, 93", "Unión bendecida y compromisos duraderos."),
    (63, "Asesino", "clasica", "Bandido, Escalera, Cuerno, Policía, Sombras", "Ogún / San Pedro", "43, 50, 76", "Precaución ante intenciones desleales ajenas."),
    (64, "Muerto grande", "clasica", "Falso, Reloj, Campana, Tiro, Gran espíritu", "Oyá / Virgen de la Candelaria", "8, 16, 80", "Presencia de un ancestro venerable y protector."),
    (65, "Comida", "clasica", "Oshún, Brujo, Cárcel, Cazuela, Banquete", "Ochún / Caridad del Cobre", "12, 49, 84", "Celebración, mesa servida y prosperidad del hogar."),
    (66, "Diablo", "clasica", "Carnaval, Máscara, Pozo, Carbón, Fuego", "Eleguá / San Antonio", "32, 59, 83", "Tentaciones tentadoras que requieren templanza."),
    (67, "Puñalada", "clasica", "Relámpago, Autoridad, Herida, Reloj, Tajo", "Ogún / San Pedro", "41, 73, 94", "Corte tajante de situaciones insostenibles."),
    (68, "Grande", "clasica", "Templo, Globo, Circo, Palma, Altura", "Obatalá / Virgen de las Mercedes", "56, 78, 88", "Crecimiento, proyectos monumentales y respeto."),
    (69, "Pozo", "clasica", "Fango, Barco, Reloj, Río, Hondo", "Yemayá / Virgen de Regla", "23, 70, 99", "Profundidades emocionales y secretos guardados."),
    (70, "Teléfono", "clasica", "Tiro, Barril, Sapo, Arco, Llamada", "Eleguá / San Antonio", "7, 18, 22", "Llamada decisiva con noticias de fortuna."),
    (71, "Fusil", "clasica", "Perro, Sombrero, Soldado, Baile, Puntería", "Ogún / San Pedro", "15, 51, 95", "Defensa de lo propio y puntería afinada."),
    (72, "Buey", "clasica", "Collar, Ferrocarril, Jarro, Látigo, Yunta", "Babalú Ayé / San Lázaro", "28, 46, 79", "Fuerza tranquila y trabajo incansable."),
    (73, "Navaja", "clasica", "Corte, Manzana, Parque, Bandera, Filo", "Ogún / San Pedro", "3, 43, 67", "Decisiones rápidas y corte de lazos dañinos."),
    (74, "Papalote", "clasica", "Militar, Serpiente, Ruina, Corona, Viento", "Oyá / Virgen de la Candelaria", "2, 77, 92", "Elevación espiritual con los pies en la tierra."),
    (75, "Cine", "clasica", "Guitarra, Pito, Novio, Estrella, Película", "Ochún / Caridad del Cobre", "13, 58, 60", "Fantasía, entretenimiento y revelaciones."),
    (76, "Humo", "clasica", "Hierro, Bomba, Pájaro, Reloj, Neblina", "Oyá / Virgen de la Candelaria", "63, 85, 96", "Señales que anuncian fuego o cambios de viento."),
    (77, "Banderas", "clasica", "Yúa, Muletas, Guerra, Trono, Triunfo", "Changó / Santa Bárbara", "11, 17, 39", "Victoria en causas justas y orgullo legítimo."),
    (78, "Obispo", "clasica", "Sarcófago, Ataúd, Luna, Viento, Mitra", "Obatalá / Virgen de las Mercedes", "14, 38, 68", "Autoridad religiosa y consejo solemne."),
    (79, "Tren", "clasica", "Coche, Abogado, Lagarto, Botella, Rieles", "Ogún / San Pedro", "1, 41, 52", "Viaje seguro hacia metas ambiciosas sobre rieles."),
    (80, "Vieja", "clasica", "Buena suerte, Trompo, Cama, Sol, Abuela", "Obatalá / Virgen de las Mercedes", "24, 57, 64", "Sabiduría ancestral, bendición de abuela y fortuna."),
    (81, "Teatro", "clasica", "Actor, Ingeniero, Barco, Reloj, Escenario", "Ochún / Caridad del Cobre", "18, 23, 75", "Representaciones sociales y éxito de imagen."),
    (82, "Madre", "clasica", "León, Bautizo, Tragedia, Flor, Amor", "Yemayá / Virgen de Regla", "27, 56, 88", "Amor protector incondicional y refugio seguro."),
    (83, "Tragedia", "clasica", "Limosnero, Madera, Bastón, Muerte, Choque", "Oyá / Virgen de la Candelaria", "32, 44, 66", "Superación de adversidades mediante la fe."),
    (84, "Sangre", "clasica", "Ciego, Banquete, Hacha, Oro, Linaje", "Changó / Santa Bárbara", "4, 40, 65", "Lazos familiares estrechos y pasión desbordante."),
    (85, "Reloj", "clasica", "Tiempo, Espejo, Águila, Policía, Minutero", "Obatalá / Virgen de las Mercedes", "36, 48, 50", "La hora propicia ha llegado; puntualidad sagrada."),
    (86, "Convento", "clasica", "Tijeras, Monja, Fuego, Carretilla, Silencio", "Obatalá / Virgen de las Mercedes", "5, 40, 80", "Retiro prudente y tranquilidad de conciencia."),
    (87, "Plátano", "clasica", "Fuego, Toro, Espada, Cueva, Racimo", "Changó / Santa Bárbara", "16, 46, 61", "Ofrenda fértil y fortaleza en el tronco."),
    (88, "Hojas", "clasica", "Aduana, Trompeta, Muerte, Vidrio, Viento", "Osain / San Silvestre", "6, 42, 68", "Hierbas medicinales y baños de despojo."),
    (89, "Cometa", "clasica", "Lotería, Melón, Anciano, Tambor, Cola", "Oyá / Virgen de la Candelaria", "49, 59, 92", "Golpe de suerte celestial que cruza el cielo."),
    (90, "Viejo", "clasica", "Esclavo, Dinero, Cruz, Espejo, Bastón", "Babalú Ayé / San Lázaro", "9, 45, 98", "Experiencia vivida, consejo y respeto a mayores."),
    (91, "Tranvía", "clasica", "Pájaro, Limosna, Bolso, Carta, Rueda", "Eleguá / San Antonio", "19, 47, 52", "Camino trazado sin desvíos hacia el destino."),
    (92, "Avión", "clasica", "Globo, Estrella, Cuba, Nube, Vuelo", "Obatalá / Virgen de las Mercedes", "26, 60, 74", "Grandes aspiraciones que toman altura."),
    (93, "Sortija", "clasica", "Revolución, General, Joya, Anillo, Oro", "Ochún / Caridad del Cobre", "25, 34, 62", "Compromiso de palabra y alianza virtuosa."),
    (94, "Machete", "clasica", "Mariposa, Habana, Cuchillo, Flores, Caña", "Ogún / San Pedro", "2, 58, 67", "Abrecaminos en la manigua y corte decisivo."),
    (95, "Guerra", "clasica", "Perro grande, Espada, Dragón, Fuego, Lucha", "Ogún / San Pedro", "15, 51, 71", "Batalla por tus derechos donde triunfa la verdad."),
    (96, "Desafío", "clasica", "Zapato, Médico, Pavo, Bandera, Duelo", "Changó / Santa Bárbara", "31, 76, 84", "Aceptación valiente de retos trascendentales."),
    (97, "Grillo", "clasica", "Limosnero, Manta, Viejo, Miedo, Canto", "Eleguá / San Antonio", "29, 57, 80", "Canto que alegra la noche y guía en lo oscuro."),
    (98, "Entierro", "clasica", "Traición, Santo, Piano, Muerto, Fin", "Oyá / Virgen de la Candelaria", "8, 33, 44", "Cierre definitivo de etapas pasadas; renacimiento."),
    (99, "Serpiente", "clasica", "Carbonero, Pozo, Brujo, Cueva, Escama", "Eleguá / San Antonio", "21, 37, 69", "Transformación total y astucia instintiva."),
    (100, "Dios", "clasica", "Inodoro, Escoba, Muerte, Fin, Corona", "Olofin / Olodumare", "1, 12, 80", "El Todo, la causa primera y la bendición infinita.")
]

def generate_historical_draws(days=180):
    """
    Genera 180 días de sorteos históricos para Florida, Georgia y NY.
    Garantiza que los tiros recientes conocidos (Nov 7-9 2026) se mantengan exactamente.
    """
    random.seed(42) # Semilla fija para reproducibilidad determinista
    
    # Sorteos recientes verificados
    known_draws = {
        ("florida", "evening", "2026-11-09"): ("4-1-5", "3-1-0-8", "15", "415", "31", "08"),
        ("florida", "midday", "2026-11-09"): ("9-2-1", "1-1-2-4", "21", "921", "11", "24"),
        ("florida", "evening", "2026-11-08"): ("2-4-6", "7-0-1-3", "46", "246", "70", "13"),
        ("florida", "midday", "2026-11-08"): ("5-9-2", "3-7-6-1", "92", "592", "37", "61"),
        ("florida", "evening", "2026-11-07"): ("8-0-4", "5-5-9-8", "04", "804", "55", "98"),
        ("georgia", "evening", "2026-11-09"): ("1-6-7", "4-0-5-2", "67", "167", "40", "52"),
        ("georgia", "midday", "2026-11-09"): ("4-0-3", "1-8-7-6", "03", "403", "18", "76"),
        ("new_york", "evening", "2026-11-09"): ("3-8-8", "0-5-2-9", "88", "388", "05", "29"),
    }
    
    base_date = datetime.date(2026, 11, 9)
    draws = []
    
    # Loterías y horarios
    schedules = [
        ("florida", "evening", "21:45", "FL-EVE"),
        ("florida", "midday", "13:30", "FL-MID"),
        ("georgia", "evening", "19:00", "GA-EVE"),
        ("georgia", "midday", "12:29", "GA-MID"),
        ("new_york", "evening", "22:30", "NY-EVE"),
    ]
    
    for i in range(days):
        current_date = base_date - datetime.timedelta(days=i)
        date_str = current_date.strftime("%Y-%m-%d")
        compact_date = current_date.strftime("%Y%m%d")
        
        for lottery, period, draw_time, id_prefix in schedules:
            draw_id = f"{id_prefix}-{compact_date}"
            key = (lottery, period, date_str)
            
            if key in known_draws:
                p3_raw, p4_raw, fijo, centena, c1, c2 = known_draws[key]
            else:
                d1 = random.randint(0, 9)
                d2 = random.randint(0, 9)
                d3 = random.randint(0, 9)
                d4 = random.randint(0, 9)
                d5 = random.randint(0, 9)
                d6 = random.randint(0, 9)
                d7 = random.randint(0, 9)
                
                p3_raw = f"{d1}-{d2}-{d3}"
                p4_raw = f"{d4}-{d5}-{d6}-{d7}"
                centena = f"{d1}{d2}{d3}"
                fijo = f"{d2}{d3}"
                c1 = f"{d4}{d5}"
                c2 = f"{d6}{d7}"
            
            draw_entry = {
                "id": draw_id,
                "lottery": lottery,
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
                "created_at": int(datetime.datetime(current_date.year, current_date.month, current_date.day, 12, 0).timestamp() * 1000)
            }
            draws.append(draw_entry)
            
    # Ordenar por fecha DESC, draw_time DESC
    draws.sort(key=lambda x: (x["draw_date"], x["draw_time"]), reverse=True)
    return draws

def build_all():
    print("[Seed Generator] Iniciando generación de semilla histórica y Charada...")
    os.makedirs("assets/seed", exist_ok=True)
    os.makedirs("public", exist_ok=True)
    
    db_path = "assets/seed/bolitero_seed.db"
    json_path = "assets/seed/charada_seed.json"
    latest_path = "public/latest.json"
    history_path = "public/history.json"
    poll_path = "public/daily_poll.json"
    
    if os.path.exists(db_path):
        os.remove(db_path)
        
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 1. Crear tabla de Charada con soporte de deidades y acompañantes
    cursor.execute("""
    CREATE TABLE charada_entries (
        number INTEGER PRIMARY KEY,
        primary_name TEXT NOT NULL,
        category TEXT DEFAULT 'clasica',
        synonyms TEXT NOT NULL,
        deity TEXT,
        accompanying TEXT,
        description TEXT
    );
    """)
    
    for row in CHARADA_100_FULL:
        cursor.execute("""
        INSERT INTO charada_entries (number, primary_name, category, synonyms, deity, accompanying, description)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """, row)
        
    # 2. Crear tabla de Sorteos con índices analíticos
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
    
    cursor.execute("CREATE INDEX idx_draws_date_lottery ON local_draws (draw_date DESC, lottery, period);")
    cursor.execute("CREATE INDEX idx_draws_fijo ON local_draws (fijo);")
    
    # 3. Crear tabla de apuestas de laboratorio
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
    cursor.execute("CREATE INDEX idx_lab_pending ON lab_plays (status, draw_date, lottery, period);")
    
    # Insertar 180 días de sorteos históricos (~900 tiros)
    draws = generate_historical_draws(days=180)
    for d in draws:
        cursor.execute("""
        INSERT INTO local_draws (id, lottery, period, draw_date, draw_time, pick3_raw, pick4_raw, fijo, centena, corrido1, corrido2, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            d["id"], d["lottery"], d["period"], d["draw_date"], d["draw_time"],
            d["pick3_raw"], d["pick4_raw"], d["fijo"], d["centena"],
            d["corrido1"], d["corrido2"], d["status"], d["created_at"]
        ))
        
    conn.commit()
    conn.close()
    print(f"[Seed Generator] Base SQLite generada con éxito ({len(draws)} sorteos): {db_path}")
    
    # Exportar Charada JSON
    charada_dict = [
        {
            "number": r[0],
            "primary_name": r[1],
            "category": r[2],
            "synonyms": r[3],
            "deity": r[4],
            "accompanying": r[5],
            "description": r[6]
        }
        for r in CHARADA_100_FULL
    ]
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(charada_dict, f, ensure_ascii=False, indent=2)
    print(f"[Seed Generator] JSON Charada exportado: {json_path}")
    
    # Exportar latest.json (últimos 2 días de sorteos)
    latest_draws = draws[:12]
    latest_payload = {
        "version": 1,
        "updated_at": "2026-11-10T14:00:00Z",
        "draws": latest_draws
    }
    with open(latest_path, "w", encoding="utf-8") as f:
        json.dump(latest_payload, f, ensure_ascii=False, indent=2)
    print(f"[Seed Generator] latest.json exportado ({len(latest_draws)} sorteos): {latest_path}")
    
    # Exportar history.json (acumulado histórico de 180 días)
    history_payload = {
        "version": 1,
        "updated_at": "2026-11-10T14:00:00Z",
        "total_draws": len(draws),
        "draws": draws
    }
    with open(history_path, "w", encoding="utf-8") as f:
        json.dump(history_payload, f, ensure_ascii=False, indent=2)
    print(f"[Seed Generator] history.json exportado ({len(draws)} sorteos): {history_path}")
    
    # Exportar daily_poll.json inicial
    poll_payload = {
        "poll_id": "2026-11-10",
        "question": "¿Cuál es tu número fijo para el sorteo de hoy?",
        "closes_at": "2026-11-10T21:30:00Z",
        "total_votes": 348,
        "top_picks": [
            {"number": "15", "charada": "Perro", "votes": 82, "percentage": 23.5},
            {"number": "21", "charada": "Majá", "votes": 64, "percentage": 18.4},
            {"number": "04", "charada": "Gato", "votes": 49, "percentage": 14.1},
            {"number": "77", "charada": "Banderas", "votes": 38, "percentage": 10.9},
            {"number": "88", "charada": "Hojas", "votes": 31, "percentage": 8.9}
        ]
    }
    with open(poll_path, "w", encoding="utf-8") as f:
        json.dump(poll_payload, f, ensure_ascii=False, indent=2)
    print(f"[Seed Generator] daily_poll.json exportado: {poll_path}")

if __name__ == "__main__":
    build_all()
