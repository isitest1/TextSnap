# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in TextSnap, please **do not** open a public GitHub issue.

Instead, report it privately by emailing: **kouhei1@gmail.com**

Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You can expect an acknowledgment within 48 hours and a status update within 7 days.

## Security Design

TextSnap is designed to minimize its attack surface:

- All OCR processing happens locally on-device using Apple Vision
- No network connections are made — no telemetry, no cloud APIs
- Captured images and recognized text are never written to disk
- No user accounts or authentication
- App Sandbox is currently disabled; Hardened Runtime is enabled
