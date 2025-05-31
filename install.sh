#!/bin/bash
# EduBox Installation Script
# Installs all necessary software for the EduBox education platform

set -e  # Exit on error

echo "======================================"
echo "EduBox Installation Script v1.0"
echo "======================================"
echo

# Check if running on Raspberry Pi
if [ ! -f /proc/cpuinfo ] || ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo "Warning: This script is optimized for Raspberry Pi"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
echo "1. Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
echo "2. Installing dependencies..."
sudo apt-get install -y \
    python3 python3-pip python3-venv \
    nginx \
    git \
    hostapd dnsmasq \
    nodejs npm \
    sqlite3 \
    rsync \
    htop \
    ufw

# Create EduBox user and directories
echo "3. Setting up EduBox user and directories..."
sudo useradd -m -s /bin/bash edubox || echo "User edubox already exists"
sudo mkdir -p /opt/edubox/{content,logs,config,backup}
sudo chown -R edubox:edubox /opt/edubox

# Install KA Lite
echo "4. Installing KA Lite (Offline Khan Academy)..."
sudo -u edubox python3 -m venv /opt/edubox/venv
sudo -u edubox /opt/edubox/venv/bin/pip install ka-lite

# Initialize KA Lite
echo "5. Initializing KA Lite..."
sudo -u edubox /opt/edubox/venv/bin/kalite manage setup --username=admin --password=edubox123 --noinput

# Install Kiwix (Offline Wikipedia)
echo "6. Installing Kiwix..."
cd /tmp
wget https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-armhf.tar.gz
tar -xzf kiwix-tools_linux-armhf.tar.gz
sudo cp kiwix-tools*/kiwix-serve /usr/local/bin/
rm -rf kiwix-tools*

# Configure WiFi Access Point
echo "7. Configuring WiFi Access Point..."
sudo tee /etc/hostapd/hostapd.conf > /dev/null <<EOF
interface=wlan0
driver=nl80211
ssid=EduBox
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=0
EOF

# Configure DHCP
echo "8. Configuring DHCP server..."
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
domain=edubox.local
address=/edubox.local/192.168.4.1
EOF

# Configure network interfaces
echo "9. Configuring network interfaces..."
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

# Configure nginx
echo "10. Configuring web server..."
sudo tee /etc/nginx/sites-available/edubox > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;
    
    location / {
        root /opt/edubox/portal;
        index index.html;
    }
    
    location /khan/ {
        proxy_pass http://localhost:8008/;
    }
    
    location /wikipedia/ {
        proxy_pass http://localhost:8080/;
    }
    
    location /content/ {
        alias /opt/edubox/content/;
        autoindex on;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/edubox /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create portal page
echo "11. Creating EduBox portal..."
sudo mkdir -p /opt/edubox/portal
sudo tee /opt/edubox/portal/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduBox - Free Education for All</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f0f0f0;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            text-align: center;
        }
        .resource-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .resource-card {
            background: #3498db;
            color: white;
            padding: 20px;
            border-radius: 5px;
            text-align: center;
            text-decoration: none;
            transition: transform 0.2s;
        }
        .resource-card:hover {
            transform: scale(1.05);
        }
        .resource-card h2 {
            margin: 10px 0;
            font-size: 1.5em;
        }
        .stats {
            text-align: center;
            margin: 20px 0;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌍 Welcome to EduBox</h1>
        <p class="stats">Free, Offline Education for Everyone</p>
        
        <div class="resource-grid">
            <a href="/khan/" class="resource-card" style="background: #e74c3c;">
                <h2>📚 Khan Academy</h2>
                <p>Math, Science, History & More</p>
            </a>
            
            <a href="/wikipedia/" class="resource-card" style="background: #2ecc71;">
                <h2>📖 Wikipedia</h2>
                <p>Encyclopedia in Your Language</p>
            </a>
            
            <a href="/content/videos/" class="resource-card" style="background: #9b59b6;">
                <h2>🎬 Educational Videos</h2>
                <p>Learn Through Video</p>
            </a>
            
            <a href="/content/books/" class="resource-card" style="background: #f39c12;">
                <h2>📚 E-Books</h2>
                <p>Digital Library</p>
            </a>
        </div>
        
        <div class="stats" style="margin-top: 40px;">
            <p><strong>No Internet Required!</strong></p>
            <p>All content is stored locally on this EduBox device.</p>
        </div>
    </div>
</body>
</html>
EOF

# Create systemd services
echo "12. Creating system services..."
sudo tee /etc/systemd/system/edubox-kalite.service > /dev/null <<EOF
[Unit]
Description=EduBox KA Lite Server
After=network.target

[Service]
Type=simple
User=edubox
WorkingDirectory=/opt/edubox
ExecStart=/opt/edubox/venv/bin/kalite start --foreground
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/edubox-kiwix.service > /dev/null <<EOF
[Unit]
Description=EduBox Kiwix Server
After=network.target

[Service]
Type=simple
User=edubox
WorkingDirectory=/opt/edubox/content
ExecStart=/usr/local/bin/kiwix-serve --port=8080 *.zim
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable services
echo "13. Enabling services..."
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable nginx
sudo systemctl enable edubox-kalite
sudo systemctl enable edubox-kiwix

# Configure firewall
echo "14. Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 67/udp
sudo ufw allow 68/udp
sudo ufw --force enable

# Download initial content
echo "15. Preparing for content download..."
echo "Please download content files separately due to size:"
echo "- Khan Academy videos: Use 'kalite manage retrievecontentpack download en.zip'"
echo "- Wikipedia ZIM files: Download from https://wiki.kiwix.org/wiki/Content"
echo

# Create content structure
sudo -u edubox mkdir -p /opt/edubox/content/{videos,books,curriculum}

# Final setup
echo "16. Final configuration..."
sudo chown -R edubox:edubox /opt/edubox

echo
echo "======================================"
echo "EduBox Installation Complete!"
echo "======================================"
echo
echo "Next steps:"
echo "1. Reboot your Raspberry Pi: sudo reboot"
echo "2. Connect to WiFi network 'EduBox'"
echo "3. Open browser to http://192.168.4.1"
echo "4. Download content packs as instructed above"
echo
echo "Default admin credentials:"
echo "Username: admin"
echo "Password: edubox123"
echo
echo "Remember to change the password!"