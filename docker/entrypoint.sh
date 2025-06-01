#!/bin/bash
# EduBox Docker Entrypoint Script
set -e

echo "==============================================="
echo "Starting EduBox Education Platform"
echo "==============================================="

# Function to download sample content
download_sample_content() {
    echo "Downloading sample educational content..."
    
    # Create a simple English Wikipedia if no content exists
    if [ -z "$(ls -A /opt/edubox/content/*.zim 2>/dev/null)" ]; then
        echo "No ZIM files found. Would you like to download a sample?"
        echo "Note: This is optional. You can add your own ZIM files later."
        
        # Create README with instructions
        cat > /opt/edubox/content/README.txt << 'EOF'
Welcome to EduBox!

This directory should contain ZIM files for offline content.

To add educational content:
1. Download ZIM files from https://download.kiwix.org/zim/
2. Place them in this directory (/opt/edubox/content/)
3. Restart the container

Recommended content:
- Wikipedia in your language
- Khan Academy videos
- Project Gutenberg books
- Stack Overflow
- TED Talks

Example download commands:
# Simple English Wikipedia (~200MB)
wget https://download.kiwix.org/zim/wikipedia/wikipedia_en_simple_all_mini_2024-01.zim

# Khan Academy (~37GB)
wget https://download.kiwix.org/zim/khan-academy/khan-academy-videos_en_2023-11.zim

# Project Gutenberg Books (~68GB)
wget https://download.kiwix.org/zim/gutenberg/gutenberg_en_all_2023-08.zim
EOF
        
        # Optionally download a tiny sample (commented out by default)
        # echo "Downloading Wikipedia Simple English (mini version, ~200MB)..."
        # wget -q --show-progress https://download.kiwix.org/zim/wikipedia/wikipedia_en_simple_all_mini_2024-01.zim \
        #     -O /opt/edubox/content/wikipedia_simple.zim || echo "Download failed, continuing without sample content"
    fi
}

# Initialize directories
echo "Initializing directories..."
mkdir -p /opt/edubox/{content,logs,backup,config}
mkdir -p /var/log/nginx

# Set permissions
echo "Setting permissions..."
chown -R edubox:edubox /opt/edubox/content /opt/edubox/logs /opt/edubox/backup /opt/edubox/config
chown -R www-data:www-data /var/log/nginx

# Check for content
download_sample_content

# Create or update portal page
if [ ! -f /opt/edubox/portal/index.html ] || [ "$EDUBOX_UPDATE_PORTAL" = "true" ]; then
    echo "Creating portal page..."
    mkdir -p /opt/edubox/portal
    cat > /opt/edubox/portal/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduBox - Free Offline Education</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 2rem 0;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        .header p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        .resources {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .resource-card {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .resource-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }
        .resource-card h2 {
            color: #2c3e50;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .resource-card .icon {
            font-size: 2rem;
        }
        .resource-card p {
            color: #666;
            margin-bottom: 1rem;
        }
        .resource-card .status {
            font-size: 0.9rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            display: inline-block;
        }
        .status.available {
            background: #d4edda;
            color: #155724;
        }
        .status.setup {
            background: #fff3cd;
            color: #856404;
        }
        .info-section {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            margin-top: 3rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .info-section h2 {
            color: #2c3e50;
            margin-bottom: 1rem;
        }
        .info-section ul {
            margin-left: 2rem;
        }
        .info-section li {
            margin-bottom: 0.5rem;
        }
        .footer {
            text-align: center;
            padding: 2rem;
            color: #666;
            margin-top: 3rem;
        }
        @media (max-width: 768px) {
            .header h1 { font-size: 2rem; }
            .resources { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌍 EduBox</h1>
        <p>Free Offline Education for Everyone</p>
    </div>
    
    <div class="container">
        <div class="resources">
            <a href="/wikipedia/" class="resource-card">
                <h2><span class="icon">📚</span> Wikipedia</h2>
                <p>Access the world's largest encyclopedia offline in multiple languages</p>
                <span class="status setup">Requires ZIM files</span>
            </a>
            
            <a href="/content/" class="resource-card">
                <h2><span class="icon">📁</span> Content Library</h2>
                <p>Browse and download educational materials and resources</p>
                <span class="status available">Available</span>
            </a>
            
            <div class="resource-card">
                <h2><span class="icon">🎓</span> Khan Academy</h2>
                <p>World-class education in math, science, and more</p>
                <span class="status setup">Coming Soon</span>
            </div>
            
            <div class="resource-card">
                <h2><span class="icon">📖</span> E-Books</h2>
                <p>Digital library with thousands of free books</p>
                <span class="status setup">Coming Soon</span>
            </div>
            
            <div class="resource-card">
                <h2><span class="icon">🎬</span> Educational Videos</h2>
                <p>Learn through video tutorials and lectures</p>
                <span class="status setup">Coming Soon</span>
            </div>
            
            <div class="resource-card">
                <h2><span class="icon">👩‍💻</span> Programming</h2>
                <p>Learn to code with offline tutorials and documentation</p>
                <span class="status setup">Coming Soon</span>
            </div>
        </div>
        
        <div class="info-section">
            <h2>📋 Getting Started</h2>
            <p>To add educational content to your EduBox:</p>
            <ol>
                <li>Download ZIM files from the <a href="https://download.kiwix.org/zim/" target="_blank">Kiwix Library</a></li>
                <li>Place the .zim files in the content directory</li>
                <li>Restart the EduBox container</li>
                <li>Access the content through this portal</li>
            </ol>
            
            <h3 style="margin-top: 1.5rem;">Recommended Content:</h3>
            <ul>
                <li><strong>Wikipedia</strong> - Available in 300+ languages</li>
                <li><strong>Khan Academy</strong> - Complete K-12 curriculum</li>
                <li><strong>Project Gutenberg</strong> - 70,000+ free books</li>
                <li><strong>Stack Overflow</strong> - Programming Q&A</li>
                <li><strong>TED Talks</strong> - Inspiring educational videos</li>
            </ul>
        </div>
    </div>
    
    <div class="footer">
        <p>EduBox - Bringing Education to Everyone, Everywhere</p>
        <p>No Internet Required • Solar Powered • Free Forever</p>
    </div>
</body>
</html>
EOF
    chown -R edubox:edubox /opt/edubox/portal
fi

# Display startup information
echo "==============================================="
echo "EduBox is starting with the following configuration:"
echo "  - Web Portal: http://localhost/"
echo "  - Wikipedia/Kiwix: http://localhost/wikipedia/"
echo "  - Content Browser: http://localhost/content/"
echo "  - Logs: /opt/edubox/logs/"
echo "==============================================="

# Check if we have any ZIM files
if ls /opt/edubox/content/*.zim 1> /dev/null 2>&1; then
    echo "Found ZIM files:"
    ls -lh /opt/edubox/content/*.zim
else
    echo "No ZIM files found. Wikipedia will not be available until you add content."
    echo "See /opt/edubox/content/README.txt for instructions."
fi

echo "==============================================="
echo "Starting supervisord..."

# Execute the command passed to the container
exec "$@"
