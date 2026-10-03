"""Placeholder until a Telegram session string is configured.

The real server refuses to start without an authorized session. This keeps
the Railway health check green and tells clients what is missing.
"""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

BODY = (
    b'{"error":"telegram_session_not_configured",'
    b'"hint":"Set TELEGRAM_API_ID, TELEGRAM_API_HASH and '
    b'TELEGRAM_SESSION_STRING, then redeploy."}\n'
)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        self._reply()

    def do_POST(self) -> None:
        self._reply()

    def do_DELETE(self) -> None:
        self._reply()

    def _reply(self) -> None:
        self.send_response(503)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(BODY)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(BODY)

    def log_message(self, fmt: str, *args: object) -> None:
        return


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 8765), Handler).serve_forever()
