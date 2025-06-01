# EduBox: Open-Source Offline Education Platform

## Mission
Bring quality education to the 258.4 million children worldwide who lack access to schools and internet, using low-cost, solar-powered technology.

## What is EduBox?
EduBox is a $100 solar-powered education server that provides:
- Complete offline access to Khan Academy (via KA Lite)
- Wikipedia in multiple languages
- Educational videos and interactive content
- Local curriculum materials
- Progress tracking for students
- Works with any WiFi-enabled device (phones, tablets, old laptops)

## Key Features
- **Cost**: Under $100 including solar panel
- **Capacity**: Serves 500+ students simultaneously
- **Content**: 50GB+ of curated educational materials
- **Languages**: Supports 40+ languages
- **Power**: Runs on solar power or battery
- **Updates**: Content can be updated via USB when internet is available

## Hardware Requirements
- Raspberry Pi 4 (4GB RAM): $55
- 64GB microSD card: $10
- Solar panel (20W) + battery: $25
- WiFi antenna (extended range): $5
- Weatherproof case: $5
- **Total: ~$100**

## Software Stack
- **OS**: Raspberry Pi OS Lite
- **Content Server**: KA Lite (offline Khan Academy)
- **Additional Content**: RACHEL, Kiwix (offline Wikipedia)
- **Management**: Custom EduBox interface
- **Languages**: Python, JavaScript, HTML/CSS

## Impact Goals
- Reach 1 million children in first 2 years
- Partner with 1,000 schools in developing countries
- Train 10,000 teachers
- Support 40+ languages
- Create local job opportunities for maintenance

## 🚀 Quick Start

### 🐳 Using Docker (Recommended)

#### Docker Compose (Easiest)
```bash
# Clone the repository
git clone https://github.com/yinzara/edubox.git
cd edubox

# Build and start EduBox
docker-compose up -d

# Access the portal
open http://localhost
```

#### Docker Run
```bash
# Build the image
docker build -t edubox:latest .

# Run the container
docker run -d \
  --name edubox \
  -p 80:80 \
  -v $(pwd)/content:/opt/edubox/content \
  -v $(pwd)/logs:/opt/edubox/logs \
  edubox:latest
```

#### Adding Educational Content
1. Download ZIM files from [Kiwix Library](https://download.kiwix.org/zim/)
2. Place files in the `content/` directory
3. Restart the container: `docker restart edubox`
4. Access Wikipedia directly at http://localhost:8080

Recommended starter content:
- [Simple English Wikipedia](https://download.kiwix.org/zim/wikipedia/) (~200MB)
- [Khan Academy](https://download.kiwix.org/zim/khan-academy-videos/)
- [Project Gutenberg Books](https://download.kiwix.org/zim/gutenberg/)

### 🔧 Manual Installation (Raspberry Pi)
```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/yinzara/edubox/main/install.sh | bash
```

### 🛠️ Troubleshooting

**Port 80 not accessible?**
If you built the container before June 1, 2025, run:
```bash
./fix-nginx.sh
```
Then rebuild for a permanent fix:
```bash
docker-compose down && docker-compose build --no-cache && docker-compose up -d
```

### 🌐 Access Points

- **Main Portal**: http://localhost/
- **Wikipedia/Kiwix**: http://localhost:8080/
- **Content Browser**: http://localhost/content/

**Note**: For the best Wikipedia experience, always use port 8080 directly.

## Getting Started
1. [Build Your Own EduBox](docs/build-guide.md)
2. [Deploy in Your Community](docs/deployment-guide.md)
3. [Contribute to Development](docs/contributing.md)
4. [Partner With Us](docs/partnerships.md)

## Current Partners
- Foundation for Learning Equality
- Raspberry Pi Foundation
- World Possible (RACHEL)
- Khan Academy
- Local NGOs in 15+ countries

## Open Source
All code, documentation, and content curation lists are available under MIT License.

---
*"Education is the most powerful weapon which you can use to change the world." - Nelson Mandela*