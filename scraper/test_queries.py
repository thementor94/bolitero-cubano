import sqlite3
import datetime

def test_database_queries():
    conn = sqlite3.connect("assets/seed/bolitero_seed.db")
    cursor = conn.cursor()

    # 1. Test total draws and charada entries
    cursor.execute("SELECT COUNT(*) FROM local_draws")
    total_draws = cursor.fetchone()[0]
    assert total_draws >= 900, f"Expected at least 900 draws, got {total_draws}"

    cursor.execute("SELECT COUNT(*) FROM charada_entries")
    total_charada = cursor.fetchone()[0]
    assert total_charada == 100, f"Expected 100 charada entries, got {total_charada}"

    # 2. Test Hot Numbers query
    cursor.execute("""
        SELECT fijo, COUNT(*) as freq, MAX(draw_date) as last_date
        FROM local_draws
        WHERE lottery = 'florida' AND draw_date >= date('2026-11-09', '-30 days')
        GROUP BY fijo
        ORDER BY freq DESC, last_date DESC
        LIMIT 10;
    """)
    hot_numbers = cursor.fetchall()
    assert len(hot_numbers) == 10, f"Expected 10 hot numbers, got {len(hot_numbers)}"
    print(f"[OK] Top 3 Hot Numbers (Florida 30d): {hot_numbers[:3]}")

    # 3. Test Delayed Numbers query
    cursor.execute("""
        SELECT fijo, draw_date, draw_time
        FROM local_draws
        WHERE lottery = 'florida'
        ORDER BY draw_date DESC, draw_time DESC;
    """)
    draws = cursor.fetchall()
    last_seen = {}
    for idx, (fijo, d_date, d_time) in enumerate(draws):
        if fijo not in last_seen:
            last_seen[fijo] = idx

    delayed = []
    for n in range(100):
        s = f"{n:02d}"
        delay = last_seen.get(s, len(draws))
        delayed.append((s, delay))
    delayed.sort(key=lambda x: x[1], reverse=True)
    assert len(delayed) == 100
    print(f"[OK] Top 3 Delayed Numbers (Florida): {delayed[:3]}")

    # 4. Test Heatmap query (Noviembre 2026)
    cursor.execute("""
        SELECT fijo, COUNT(*) as count
        FROM local_draws
        WHERE lottery = 'florida' AND draw_date BETWEEN '2026-11-01' AND '2026-11-30'
        GROUP BY fijo;
    """)
    heat_rows = cursor.fetchall()
    assert len(heat_rows) > 0
    print(f"[OK] Heatmap records for Nov 2026: {len(heat_rows)} active numbers")

    # 5. Test Charada search
    cursor.execute("""
        SELECT number, primary_name, synonyms, deity, accompanying
        FROM charada_entries
        WHERE number = 15;
    """)
    charada_15 = cursor.fetchone()
    assert charada_15[1] == "Perro"
    assert "San Lázaro" in charada_15[3]
    print(f"[OK] Charada #15: {charada_15}")

    conn.close()
    print("[ALL DATABASE TESTS PASSED SUCCESSFULLY!]")

if __name__ == "__main__":
    test_database_queries()
