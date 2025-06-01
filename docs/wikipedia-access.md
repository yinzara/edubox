# EduBox Wikipedia/Kiwix Access

## The Issue
When accessing Wikipedia through the `/wikipedia/` path on port 80, the page loads but CSS and other resources are missing. This is because Kiwix (the Wikipedia server) uses absolute paths for its resources that don't work well with nginx reverse proxy.

## The Solution
Access Wikipedia/Kiwix directly on **port 8080**:

### ✅ Correct Way
```
http://localhost:8080/
```

This gives you the full Wikipedia experience with all formatting and functionality intact.

### ❌ Problematic Way
```
http://localhost/wikipedia/
```

This path will redirect you to port 8080 automatically.

## Why This Happens
Kiwix serves resources with paths like:
- `/skin/kiwix.css`
- `/catalog/v2/entries`
- `/common/js/app.js`

When proxied through nginx at `/wikipedia/`, these resources are requested from the wrong paths, causing 404 errors and broken formatting.

## Updated Portal
The EduBox portal now clearly indicates that Wikipedia should be accessed on port 8080 and provides direct links.

## Technical Details
While it's technically possible to create a complex nginx configuration with URL rewriting to make `/wikipedia/` work, it's much simpler and more reliable to:
1. Use port 8080 directly for Wikipedia/Kiwix
2. Use port 80 for the main EduBox portal and content browser

This approach ensures:
- Full functionality of the Wikipedia interface
- Proper loading of all resources
- Better performance (no proxy overhead)
- Simpler configuration and maintenance
