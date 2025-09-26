#!/bin/sh

# Set default values if not provided
export AUTH_API_URL=${AUTH_API_URL:-"http://auth-api:8000"}
export TODOS_API_URL=${TODOS_API_URL:-"http://todos-api:8082"}
export ZIPKIN_URL=${ZIPKIN_URL:-"http://zipkin:9411/api/v2/spans"}

# Create a simplified nginx config that doesn't require upstream services to be available
cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle Vue.js routing (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy para Auth API
    location /login {
        proxy_pass http://auth-api:8000/login;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type application/json;
    }

    # Proxy para Todos API
    location /todos {
        proxy_pass http://todos-api:8082/todos;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type application/json;
    }

    # Proxy para Zipkin
    location /zipkin {
        proxy_pass http://zipkin:9411/api/v2/spans;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type application/x-thrift;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary "Accept-Encoding";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        application/xml
        image/svg+xml;

    # Error pages
    error_page 404 /index.html;
}
EOF

# Start nginx
exec "$@"
