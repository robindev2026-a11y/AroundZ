import sqlite3
import hashlib
import os
import pathspec

DB_PATH = ".ai_cache/project_context.db"
PROJECT_ROOT = "."

def get_ignore_spec():
    ignore_files = [".gitignore", ".claudeignore"]
    patterns = [".git/", ".ai_cache/"]
    for f in ignore_files:
        if os.path.exists(f):
            with open(f, "r") as fh:
                patterns.extend(fh.readlines())
    return pathspec.PathSpec.from_lines('gitwildmatch', patterns)

def get_file_hash(path):
    hasher = hashlib.md5()
    with open(path, "rb") as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS file_cache (
            path TEXT PRIMARY KEY,
            hash TEXT,
            last_modified REAL,
            summary TEXT
        )
    ''')
    conn.commit()
    return conn

def update_cache():
    conn = init_db()
    cursor = conn.cursor()
    spec = get_ignore_spec()
    
    updated_count = 0
    total_count = 0

    for root, dirs, files in os.walk(PROJECT_ROOT):
        # Filter directories
        rel_root = os.path.relpath(root, PROJECT_ROOT)
        if rel_root != "." and spec.match_file(rel_root + "/"):
            dirs[:] = [] # Skip this directory
            continue

        for file in files:
            rel_path = os.path.join(rel_root, file)
            if spec.match_file(rel_path):
                continue
            
            total_count += 1
            full_path = os.path.join(root, file)
            try:
                current_hash = get_file_hash(full_path)
                mtime = os.path.getmtime(full_path)
                
                cursor.execute("SELECT hash FROM file_cache WHERE path = ?", (rel_path,))
                row = cursor.fetchone()
                
                if not row or row[0] != current_hash:
                    # File changed or new
                    print(f"Indexing: {rel_path}")
                    # In a real scenario, we'd call an LLM here to summarize
                    # For now, we just update the metadata
                    cursor.execute('''
                        INSERT OR REPLACE INTO file_cache (path, hash, last_modified)
                        VALUES (?, ?, ?)
                    ''', (rel_path, current_hash, mtime))
                    updated_count += 1
            except Exception as e:
                print(f"Error processing {rel_path}: {e}")

    conn.commit()
    conn.close()
    
    if updated_count > 0:
        print(f"Changes detected. Triggering vector sync...")
        import subprocess
        subprocess.run(["python3", ".ai_cache/vector_sync.py"])
    
    print(f"Cache update complete. Total: {total_count}, Updated/New: {updated_count}")

if __name__ == "__main__":
    update_cache()
