#!/bin/sh
set -e

template=/etc/nginx/nginx.conf.template
out=/etc/nginx/nginx.conf
tmp=/tmp/nginx.conf.$$

render_config() {
    echo "🔧 Rendering Nginx configuration with environment variables..."
    echo "   ACTIVE_POOL: ${ACTIVE_POOL}"
    echo "   UPSTREAM_BLUE: ${UPSTREAM_BLUE}"
    echo "   UPSTREAM_GREEN: ${UPSTREAM_GREEN}"
    
    # Replace environment variables in template
    envsubst '${UPSTREAM_BLUE} ${UPSTREAM_GREEN}' < "$template" > "$tmp"
    
    # Validate the generated config
    if nginx -t -c "$tmp" 2>/dev/null; then
        mv "$tmp" "$out"
        echo "✅ Nginx configuration rendered and validated successfully"
    else
        echo "❌ Nginx configuration validation failed"
        cat "$tmp" >&2
        rm -f "$tmp"
        exit 1
    fi
}

# Wait for upstream services to be ready
wait_for_upstream() {
    echo "⏳ Waiting for upstream services (${UPSTREAM_BLUE}, ${UPSTREAM_GREEN})..."
    
    # Simple wait loop for upstream services
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z app_blue ${PORT} && nc -z app_green ${PORT} 2>/dev/null; then
            echo "✅ Upstream services are ready"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts: Waiting for services..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ Upstream services not ready after $max_attempts attempts"
    exit 1
}

# Handle graceful shutdown
cleanup() {
    echo "🛑 Shutting down Nginx..."
    nginx -s quit
    wait
}

# Set up signal handlers
trap cleanup TERM INT

# Main execution
echo "🚀 Starting Blue/Green Nginx Load Balancer..."

# Wait for upstream services
wait_for_upstream

# Render initial configuration
render_config

# Start Nginx
echo "📡 Starting Nginx service..."
nginx -g 'daemon off;' &

# Wait for Nginx to start
sleep 2

# Monitor Nginx and reload on configuration changes if needed
nginx_pid=$!
wait $nginx_pid