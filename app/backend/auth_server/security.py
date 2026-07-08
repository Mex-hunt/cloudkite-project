import base64
import hashlib
import hmac
import json
import secrets
import time
from typing import Any

from auth_server.config import get_settings


def hash_password(password: str) -> str:
    salt = secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 120_000)
    return f"{salt}${digest.hex()}"


def verify_password(password: str, stored_hash: str) -> bool:
    salt, digest = stored_hash.split("$", 1)
    candidate = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 120_000).hex()
    return hmac.compare_digest(candidate, digest)


def base64url_encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).decode().rstrip("=")


def base64url_decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def sign(payload: str) -> str:
    secret = get_settings().token_secret.encode()
    return base64url_encode(hmac.new(secret, payload.encode(), hashlib.sha256).digest())


def create_token(subject: str, name: str) -> str:
    now = int(time.time())
    payload = {
        "jti": secrets.token_urlsafe(12),
        "sub": subject,
        "name": name,
        "iat": now,
        "exp": now + get_settings().token_ttl_seconds,
        "iss": "cloudkite-auth",
    }
    encoded_payload = base64url_encode(json.dumps(payload, separators=(",", ":")).encode())
    return f"{encoded_payload}.{sign(encoded_payload)}"


def decode_token(token: str) -> dict[str, Any]:
    try:
        encoded_payload, signature = token.split(".", 1)
    except ValueError as exc:
        raise ValueError("Malformed token") from exc

    expected_signature = sign(encoded_payload)
    if not hmac.compare_digest(signature, expected_signature):
        raise ValueError("Invalid token signature")

    payload = json.loads(base64url_decode(encoded_payload))
    if int(payload["exp"]) < int(time.time()):
        raise ValueError("Token has expired")

    return payload
