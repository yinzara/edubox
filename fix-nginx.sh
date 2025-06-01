#!/bin/bash
# Quick fix for nginx configuration issue in running container

echo "Fixing nginx configuration in EduBox container..."

# Create the symlink
docker exec edubox ln -sf /etc/nginx/sites-available/edubox /etc/nginx/sites-enabled/edubox

# Remove any default symlink
docker exec edubox rm -f /etc/nginx/sites-enabled/default

# Reload nginx
docker exec edubox nginx -s reload

echo "Done! EduBox should now be accessible at http://localhost"
echo ""
echo "To rebuild with the fix permanently:"
echo "  docker-compose down"
echo "  docker-compose build --no-cache"
echo "  docker-compose up -d"
