# EduBox Wikipedia/Kiwix Reverse Proxy Configuration

## Overview
The Wikipedia/Kiwix content is now properly accessible through the nginx reverse proxy at `/wikipedia/` on port 80, as well as directly on port 8080.

## Access Methods

### Via Reverse Proxy (Port 80)
- **URL**: http://localhost/wikipedia/
- **Advantages**: Single port access, integrated with main portal
- **How it works**: Nginx proxies all required Kiwix paths

### Direct Access (Port 8080)
- **URL**: http://localhost:8080/
- **Advantages**: Direct connection, slightly better performance
- **Use case**: When you want to bypass the proxy

## Nginx Configuration Details

The reverse proxy handles the following paths:

1. **Main Wikipedia Interface**: `/wikipedia/` → `http://localhost:8080/`
2. **Resource Paths**: All Kiwix resources are proxied:
   - `/skin/` - CSS and design resources
   - `/catalog/` - Content catalog
   - `/search/` - Search functionality
   - `/suggest/` - Search suggestions
   - `/content/` - Article content
   - `/common/` - Common resources
   - `/I/`, `/M/`, `/A/` - Image and media paths
   - Article paths like `/A/Article_Name`

3. **Special Files**: 
   - `favicon.ico`
   - `robots.txt`
   - `opensearch_desc.xml`

## Key Features

- **WebSocket Support**: For real-time features
- **Proper Redirects**: Maintains correct URLs
- **Extended Timeouts**: For large content/images
- **Security Headers**: Maintained throughout

## Testing the Proxy

```bash
# Test main page
curl -I http://localhost/wikipedia/

# Test CSS loading
curl -I http://localhost/skin/kiwix.css

# Test catalog
curl -I http://localhost/catalog/v2/entries

# Test article access (example)
curl -I http://localhost/A/Wikipedia
```

All paths should return HTTP 200 OK with appropriate content types.
