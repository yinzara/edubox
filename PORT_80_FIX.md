# EduBox Port 80 Fix

## The Issue
Your container was built with the old Dockerfile that had a bug in the nginx configuration. The nginx config file wasn't being properly linked to sites-enabled.

## Quick Fix (Already Applied)
I've run the fix script which corrected the nginx configuration in your running container. 

**Port 80 is now working!** ✅

You can access:
- Main portal: http://localhost/
- Wikipedia/Kiwix: http://localhost:8080/
- Content browser: http://localhost/content/

## Permanent Fix
To ensure this doesn't happen again when you restart the container:

```bash
# Stop and remove the current container
docker-compose down

# Rebuild with the fixed Dockerfile
docker-compose build --no-cache

# Start the new container
docker-compose up -d
```

## What Was Fixed
1. The Dockerfile now properly removes the default nginx config
2. Then creates the correct symlink for the edubox config
3. The fix is permanent in all future builds

## Testing
After rebuilding, test both ports:
```bash
# Test main portal (port 80)
curl -I http://localhost/

# Test Kiwix (port 8080)
curl -I http://localhost:8080/
```

Both should return `HTTP/1.1 200 OK`

## Summary
- ✅ Port 80 (main portal) - Now working
- ✅ Port 8080 (Kiwix/Wikipedia) - Already working
- ✅ Fix applied to running container
- ✅ Dockerfile updated for future builds

The EduBox platform is now fully operational!
