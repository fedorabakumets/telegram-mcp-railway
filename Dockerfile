FROM caddy:2-alpine AS caddy

FROM python:3.13-alpine

RUN apk add --no-cache ca-certificates git \
    && adduser -D -u 1000 appuser

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

WORKDIR /opt/telegram-mcp

# Pinned upstream. The PyPI name "telegram-mcp" belongs to a different project;
# this image runs the chigwell/telegram-mcp checkout directly.
ARG TG_MCP_REF=ffeebe86d40cd73affad919d94fbf0460922c554
RUN git init \
    && git remote add origin https://github.com/chigwell/telegram-mcp.git \
    && git fetch --depth 1 origin "$TG_MCP_REF" \
    && git checkout --detach FETCH_HEAD \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && rm -rf .git

COPY Caddyfile /etc/caddy/Caddyfile
COPY stub.py /opt/railway/stub.py
COPY entrypoint.sh /opt/railway/entrypoint.sh

RUN chmod 755 /opt/railway/entrypoint.sh \
    && mkdir -p /data/transcripts /tmp/caddy-config /tmp/caddy-data \
    && chown -R appuser:appuser /opt/telegram-mcp /opt/railway /data /tmp/caddy-config /tmp/caddy-data

USER appuser

ENV MCP_TRANSPORT=http \
    MCP_HOST=127.0.0.1 \
    MCP_PORT=8765 \
    MCP_ALLOWED_HOSTS=127.0.0.1:8765,127.0.0.1,localhost,localhost:8765 \
    TELEGRAM_TRANSCRIPT_CACHE_DIR=/data/transcripts \
    TELEGRAM_DEVICE_MODEL="Telegram MCP" \
    TELEGRAM_SYSTEM_VERSION=Railway \
    TELEGRAM_APP_VERSION=2.0.1 \
    XDG_CONFIG_HOME=/tmp/caddy-config \
    XDG_DATA_HOME=/tmp/caddy-data

EXPOSE 8080

ENTRYPOINT ["/opt/railway/entrypoint.sh"]
