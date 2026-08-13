import os
import re

SECRET_PATTERNS = [
    r'password\s*=\s*"[^"]+"',
    r'passwd\s*=\s*"[^"]+"',
    r'secret_key\s*=\s*"[^"]+"',
    r'api_key\s*=\s*"[^"]+"',
    r'access_key\s*=\s*"[^"]+"',
    r'token\s*=\s*"[^"]+"'
]


def scan_secrets():
    found = False

    for root, dirs, files in os.walk("."):
        for file in files:

            if not file.endswith(".tf"):
                continue

            path = os.path.join(root, file)

            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            for pattern in SECRET_PATTERNS:

                matches = re.finditer(pattern, content, re.IGNORECASE)

                for match in matches:
                    line_number = content[:match.start()].count("\n") + 1

                    print(
                        f"SECRET DETECTED: {path}:{line_number}"
                    )

                    found = True

    return found


if __name__ == "__main__":
    if scan_secrets():
        exit(1)

    print("No secrets detected")