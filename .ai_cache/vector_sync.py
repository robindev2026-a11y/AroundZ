import chromadb
from chromadb.utils import embedding_functions
import os
import pathspec
import hashlib

DB_PATH = ".ai_cache/vector_db"
COLLECTION_NAME = "project_files"

def get_ignore_spec():
    ignore_files = [".gitignore", ".claudeignore"]
    patterns = [".git/", ".ai_cache/", "*.png", "*.jpg", "*.jpeg", "*.pdf", "*.DS_Store"]
    for f in ignore_files:
        if os.path.exists(f):
            with open(f, "r") as fh:
                patterns.extend(fh.readlines())
    return pathspec.PathSpec.from_lines('gitwildmatch', patterns)

def chunk_text(text, size=1000, overlap=100):
    chunks = []
    for i in range(0, len(text), size - overlap):
        chunks.append(text[i:i + size])
    return chunks

def sync_vector_db():
    client = chromadb.PersistentClient(path=DB_PATH)
    # Using default embedding function (ONNX-based)
    collection = client.get_or_create_collection(name=COLLECTION_NAME)
    
    spec = get_ignore_spec()
    
    indexed_count = 0
    
    for root, dirs, files in os.walk("."):
        rel_root = os.path.relpath(root, ".")
        if rel_root != "." and spec.match_file(rel_root + "/"):
            dirs[:] = []
            continue

        for file in files:
            rel_path = os.path.join(rel_root, file)
            if spec.match_file(rel_path):
                continue
            
            full_path = os.path.join(root, file)
            try:
                with open(full_path, "r", errors="ignore") as f:
                    content = f.read()
                
                if not content.strip():
                    continue
                
                # Simple chunking
                chunks = chunk_text(content)
                ids = [f"{rel_path}_{i}" for i in range(len(chunks))]
                metadatas = [{"path": rel_path, "chunk": i} for i in range(len(chunks))]
                
                # Add to collection (upsert replaces if IDs exist)
                collection.upsert(
                    documents=chunks,
                    metadatas=metadatas,
                    ids=ids
                )
                indexed_count += 1
                if indexed_count % 10 == 0:
                    print(f"Indexed {indexed_count} files...")
            except Exception as e:
                print(f"Error indexing {rel_path}: {e}")

    print(f"Vector sync complete. Total files indexed: {indexed_count}")

if __name__ == "__main__":
    sync_vector_db()
