#!/bin/sh
set -e

template=/etc/nginx/nginx.conf.template
out=/etc/nginx/nginx.conf
tmp=/tmp/nginx.conf.tmp

render_config() {
    echo "Rendering Nginx configuration with ACTIVE_POOL=${ACTIVE_POOL}"
    echo "Blue upstream: ${UPSTREAM_BLUE}"
    echo "Green upstream: ${UPSTREAM_GREEN}"
    
    # Use envsubst to replace environment variables
    envsubst '${UPSTREAM_BLUE} ${UPSTREAM_GREEN}' < "$template" > "$tmp"
    mv "$tmp" "$out"
    
    echo "Nginx configuration rendered successfully"
    echo "Active pool: ${ACTIVE_POOL}"
}

# Wait for upstream services to be ready
wait_for_upstream() {
    echo "Waiting for upstream services to be ready..."
    # Add any waiting logic if needed
    sleep 5
}

# Initial setup
wait_for_upstream
render_config

# Start nginx
echo "Starting Nginx..."
exec nginx -g 'daemon off;'