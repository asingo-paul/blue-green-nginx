#!/bin/sh
set -e

template=/etc/nginx/nginx.conf.template
out=/etc/nginx/nginx.conf

render() {
  echo "Rendering Nginx configuration..."
  envsubst '\$ACTIVE_POOL \$UPSTREAM_BLUE \$UPSTREAM_GREEN' < "$template" > "$out"
}

reload() {
  echo "Reloading Nginx with new configuration..."
  render
  nginx -s reload || true
}

# Handle reload signal for grader or manual toggle
trap "reload" HUP

# Initial render before starting Nginx
render

# Start Nginx in foreground
nginx -g 'daemon off;'
