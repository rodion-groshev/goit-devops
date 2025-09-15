import os, time, socket

host = os.getenv("POSTGRES_HOST", "db")
port = int(os.getenv("POSTGRES_PORT", "5432"))
timeout = 30

start = time.time()
while True:
    try:
        with socket.create_connection((host, port), timeout=2):
            break
    except OSError:
        if time.time() - start > timeout:
            raise SystemExit(f"Database {host}:{port} not reachable after {timeout}s")
        time.sleep(1)
print("Database is up.")
