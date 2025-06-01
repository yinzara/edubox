# EduBox Docker Image - Production Version
# Multi-stage build for smaller final image
FROM debian:bullseye-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Kiwix tools based on architecture
RUN ARCH=$(dpkg --print-architecture) && \
    case $ARCH in \
        amd64) KIWIX_ARCH="x86_64" ;; \
        arm64|aarch64) KIWIX_ARCH="aarch64" ;; \
        armhf) KIWIX_ARCH="armhf" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    echo "Downloading kiwix-tools for $KIWIX_ARCH" && \
    wget -q https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-${KIWIX_ARCH}.tar.gz && \
    tar -xzf kiwix-tools*.tar.gz && \
    cp kiwix-tools*/kiwix-serve /usr/local/bin/ && \
    chmod +x /usr/local/bin/kiwix-serve

# Final stage
FROM debian:bullseye-slim

# Metadata
LABEL maintainer="edubox@example.com"
LABEL description="EduBox - Offline Education Platform"
LABEL version="2.0"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    nginx \
    sqlite3 \
    supervisor \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy Kiwix from builder stage
COPY --from=builder /usr/local/bin/kiwix-serve /usr/local/bin/

# Create edubox user and group
RUN groupadd -r edubox && \
    useradd -r -g edubox -m -s /bin/bash edubox

# Create directory structure with proper permissions
RUN mkdir -p /opt/edubox/{content,logs,config,backup,portal} && \
    chown -R edubox:edubox /opt/edubox

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    flask \
    gunicorn \
    requests

# Copy application files
COPY --chown=edubox:edubox install.sh /opt/edubox/
COPY --chown=edubox:edubox impact_tracker.py /opt/edubox/
COPY --chown=edubox:edubox portal/ /opt/edubox/portal/

# Copy configuration files
COPY docker/nginx.conf /etc/nginx/sites-available/edubox
COPY docker/supervisord.conf /etc/supervisor/conf.d/edubox.conf

# Set up nginx
RUN ln -sf /etc/nginx/sites-available/edubox /etc/nginx/sites-enabled/default && \
    rm -f /etc/nginx/sites-enabled/default

# Copy and set up entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 80 8080

# Define volumes for persistent data
VOLUME ["/opt/edubox/content", "/opt/edubox/logs", "/opt/edubox/backup"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Set working directory
WORKDIR /opt/edubox

# Use non-root user (commented out for now as nginx needs root)
# USER edubox

# Entrypoint and command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
