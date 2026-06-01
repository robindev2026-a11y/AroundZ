#!/bin/bash

echo "🚀 Initializing AI Context System..."

# Check for Python 3
if ! command -v python3 &> /dev/null
then
    echo "❌ Error: Python 3 is not installed."
    exit
fi

# Install requirements
echo "📦 Installing dependencies..."
python3 -m pip install -r .ai_cache/requirements.txt

# Create cache directory if it doesn't exist
mkdir -p .ai_cache/vector_db

# Run initial sync
echo "🔄 Warming up memory (this may take a minute)..."
python3 .ai_cache/update_cache.py

echo "✅ System Ready. Your AI now has memory."
