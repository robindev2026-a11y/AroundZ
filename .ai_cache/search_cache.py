import chromadb
import sys
import os

DB_PATH = ".ai_cache/vector_db"
COLLECTION_NAME = "project_files"

def search(query, n_results=5):
    if not os.path.exists(DB_PATH):
        print(f"Error: Vector DB not found at {DB_PATH}. Run update_cache.py first.")
        return

    client = chromadb.PersistentClient(path=DB_PATH)
    collection = client.get_collection(name=COLLECTION_NAME)
    
    results = collection.query(
        query_texts=[query],
        n_results=n_results
    )
    
    print(f"\n--- Semantic Search Results for: '{query}' ---")
    for i in range(len(results['documents'][0])):
        doc = results['documents'][0][i]
        meta = results['metadatas'][0][i]
        dist = results['distances'][0][i]
        print(f"\n[{i+1}] File: {meta['path']} (Relevance: {1-dist:.4f})")
        # Print first 200 chars of the chunk
        snippet = doc.replace('\n', ' ')[:200]
        print(f"    Snippet: {snippet}...")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 .ai_cache/search_cache.py 'your search query'")
    else:
        search(sys.argv[1])
