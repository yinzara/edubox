# EduBox Deployment Guide

## Quick Start

### What You'll Need
- Raspberry Pi 4 (4GB RAM recommended)
- MicroSD card (64GB minimum)
- Solar panel kit (20W) or power adapter
- WiFi antenna (optional, for extended range)
- Weatherproof case (for outdoor installations)

### Step 1: Prepare the Raspberry Pi

1. Download Raspberry Pi OS Lite from [raspberrypi.org](https://www.raspberrypi.org/software/)
2. Flash it to your SD card using [Balena Etcher](https://www.balena.io/etcher/)
3. Enable SSH by creating an empty file named `ssh` on the boot partition
4. Insert SD card and boot your Raspberry Pi

### Step 2: Run Installation

Connect to your Raspberry Pi via SSH and run:

```bash
wget https://raw.githubusercontent.com/edubox-project/edubox/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

### Step 3: Download Content

Due to size, educational content must be downloaded separately:

#### Khan Academy Content
```bash
sudo -u edubox /opt/edubox/venv/bin/kalite manage retrievecontentpack download en.zip
```

#### Wikipedia (Choose your language)
```bash
# English Wikipedia (90GB)
wget https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2024-01.zim

# Spanish Wikipedia (40GB)
wget https://download.kiwix.org/zim/wikipedia/wikipedia_es_all_maxi_2024-01.zim

# French Wikipedia (35GB)
wget https://download.kiwix.org/zim/wikipedia/wikipedia_fr_all_maxi_2024-01.zim

# Move to content directory
sudo mv *.zim /opt/edubox/content/
```

### Step 4: Solar Power Setup (Optional)

For areas without reliable electricity:

1. Connect solar panel to charge controller
2. Connect battery to charge controller
3. Connect Raspberry Pi power to battery output
4. Mount solar panel facing south (northern hemisphere) or north (southern hemisphere)
5. Ensure battery capacity can run Pi for 12+ hours

## Deployment Scenarios

### School Deployment

**Capacity**: 500+ students

1. Mount EduBox in central location
2. Use external antenna for wider coverage
3. Create student accounts in batches
4. Train teachers on content navigation
5. Set up weekly content sync if internet available

### Community Center

**Capacity**: 100-200 concurrent users

1. Install in weatherproof case
2. Mount high for better WiFi coverage
3. Create open access (no passwords)
4. Post instructions in local language
5. Designate local maintainer

### Rural Clinic/Hospital

**Focus**: Health education content

1. Curate medical and health content
2. Add local health guidelines
3. Include first-aid videos
4. Setup in waiting area
5. Train staff to assist patients

### Prison Education Program

**Security**: Restricted content only

1. Remove internet connectivity completely
2. Curate approved educational content
3. Enable progress tracking
4. Regular content audits
5. Integrate with existing programs

## Maintenance

### Daily
- Check system status: `systemctl status edubox-*`
- Monitor disk space: `df -h`
- Check active users: `who`

### Weekly
- Update content if internet available
- Backup user progress data
- Clean temporary files
- Check solar battery levels

### Monthly
- Full system backup
- Update software packages
- Review usage statistics
- Clean hardware (dust, connections)

## Troubleshooting

### WiFi Not Visible
```bash
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq
```

### Cannot Access Content
```bash
sudo systemctl restart nginx
sudo systemctl restart edubox-kalite
sudo systemctl restart edubox-kiwix
```

### Slow Performance
- Check CPU usage: `htop`
- Limit concurrent users if needed
- Upgrade to Raspberry Pi 4 8GB model
- Add cooling fan if overheating

## Scaling Your Deployment

### Multiple EduBoxes
- Use mesh networking for larger areas
- Sync content between boxes
- Central management server
- Shared user accounts

### Content Customization
- Add local curriculum
- Include regional languages
- Cultural adaptation
- Government textbooks

## Success Metrics

Track these to measure impact:
- Number of unique users per day
- Hours of content accessed
- Most popular subjects
- Student progress rates
- Teacher feedback

## Support

- GitHub: [github.com/edubox-project](https://github.com/edubox-project)
- Forum: [community.edubox.org](https://community.edubox.org)
- Email: support@edubox.org
- WhatsApp: +1-xxx-xxx-xxxx

## Contributing

Help us improve EduBox:
- Report bugs and issues
- Translate content
- Add local curriculum
- Share deployment stories
- Donate hardware