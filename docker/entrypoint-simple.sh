#!/bin/bash
# EduBox Docker Entrypoint Script - Simplified

set -e

echo "Starting EduBox initialization..."

# Create necessary directories
mkdir -p /opt/edubox/{content,logs,backup}

# Download sample content if content directory is empty
if [ -z "$(ls -A /opt/edubox/content/*.zim 2>/dev/null)" ]; then
    echo "No content found. Creating sample content..."
    
    # Create a placeholder file
    cat > /opt/edubox/content/README.txt << EOF
Welcome to EduBox!

To add Wikipedia and other educational content:
1. Download .zim files from https://download.kiwix.org/zim/
2. Place them in this directory (/opt/edubox/content/)
3. Restart the container

Recommended content for testing:
- wikipedia_en_simple_all_mini.zim (Simple English Wikipedia - small version)
- khan-academy-videos_en.zim (Khan Academy videos)

For testing, you can download a small Wikipedia file:
wget https://download.kiwix.org/zim/wikipedia/wikipedia_en_simple_all_mini_2024-01.zim
EOF

    # Optionally download a small test file (commented out to avoid long downloads during build)
    # echo "Downloading small Wikipedia sample..."
    # wget -q https://download.kiwix.org/zim/wikipedia/wikipedia_en_simple_all_mini_2024-01.zim -O /opt/edubox/content/wikipedia_simple.zim || true
fi

# Set permissions
chown -R edubox:edubox /opt/edubox/content /opt/edubox/logs /opt/edubox/backup

# Create a simple index.html if it doesn't exist
if [ ! -f /opt/edubox/portal/index.html ]; then
    echo "Creating default portal page..."
    cat > /opt/edubox/portal/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>EduBox - Offline Education Portal</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
        .resource { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Welcome to EduBox</h1>
    <p>Your offline education portal</p>
    
    <div class="resource">
        <h2><a href="/wikipedia/">Wikipedia</a></h2>
        <p>Access offline Wikipedia content (if ZIM files are loaded)</p>
    </div>
    
    <div class="resource">
        <h2><a href="/content/">Content Library</a></h2>
        <p>Browse available offline content files</p>
    </div>
    
    <div class="resource">
        <h2>Getting Started</h2>
        <p>To add educational content:</p>
        <ol>
            <li>Download ZIM files from <a href="https://download.kiwix.org/zim/">Kiwix Library</a></li>
            <li>Place them in the content directory</li>
            <li>Restart the container</li>
        </ol>
    </div>
</body>
</html>
EOF
fi

# Start supervisor
echo "Starting services..."
exec "$@"