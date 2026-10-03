# telegram-mcp on Railway

Same server as the local [chigwell/telegram-mcp](https://github.com/chigwell/telegram-mcp) install, pinned to commit `ffeebe86d40cd73affad919d94fbf0460922c554`.

The Telegram process listens only on `127.0.0.1:8765`. Caddy publishes `$PORT` and rejects every request except `/healthz` unless it carries `Authorization: Bearer $MCP_AUTH_TOKEN`. Upstream HTTP has no login of its own, so this gate is required before the service has a public URL.

Without `TELEGRAM_API_ID`, `TELEGRAM_API_HASH` and `TELEGRAM_SESSION_STRING`, the container stays up and `/mcp` returns 503. Generate the session on your own machine with `session_string_generator.py` (QR or phone code). This image does not log in to Telegram by itself.

Cursor:

```json
{
  "mcpServers": {
    "telegram": {
      "url": "https://<railway-domain>/mcp",
      "headers": {
        "Authorization": "Bearer <MCP_AUTH_TOKEN>"
      }
    }
  }
}
```

Set `TELEGRAM_EXPOSED_TOOLS=read-only` if the cloud agent should not be able to send messages.
