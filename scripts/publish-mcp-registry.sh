#!/usr/bin/env bash
#
# Publish server.json to the official MCP registry.
#
# DO NOT INSTALL THE PUBLISHER FROM npm. The npm package named
# "mcp-publisher" is NOT the official tool — it is an unrelated
# browser-automation package with no repository, no homepage and no author,
# which happens to install a binary of that name. An earlier version of this
# script told you to install from npm; had the shell then resolved that
# binary, this script would have handed it MCP_PRIVATE_KEY, the key that
# proves ownership of cybercentry.co.uk to the registry.
#
# The official publisher is a Go binary released from
# github.com/modelcontextprotocol/registry, with a signed checksums file.
# This script downloads it, VERIFIES THE SHA-256 against that file, and
# refuses to run it on a mismatch.
#
# The namespace uk.co.cybercentry/* is proved by DNS, and the private key is at
# ~/.mcp-publisher/cybercentry-dns.pem from the first publish. Registry
# tokens expire five minutes after issuance, so a login is needed every run;
# the key is what persists.
#
#   bash scripts/publish-mcp-registry.sh
set -euo pipefail

DOMAIN="cybercentry.co.uk"
KEY="${HOME}/.mcp-publisher/cybercentry-dns.pem"
REPO="modelcontextprotocol/registry"

[ -f server.json ] || { echo "run from the repository root (no server.json here)" >&2; exit 1; }
[ -f "$KEY" ] || { echo "missing DNS key: $KEY" >&2; exit 1; }

# Platform asset name.
case "$(uname -s)" in
  Linux*)  OS=linux ;;
  Darwin*) OS=darwin ;;
  MINGW*|MSYS*|CYGWIN*) OS=windows ;;
  *) echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
ASSET="mcp-publisher_${OS}_${ARCH}.tar.gz"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "== resolving the latest release =="
# Written to a file first, not piped: grep -m1 closes the pipe on its
# first match, curl then exits 23, and pipefail turns that into a failed
# run that looks like a network fault.
curl -fsSL -o "${WORK}/latest.json" "https://api.github.com/repos/${REPO}/releases/latest"
TAG="$(grep '"tag_name"' "${WORK}/latest.json" | head -1 | cut -d'"' -f4)"
[ -n "$TAG" ] || { echo "could not resolve the latest release tag" >&2; exit 1; }
VER="${TAG#v}"
echo "   ${TAG}, asset ${ASSET}"

BASE="https://github.com/${REPO}/releases/download/${TAG}"
curl -fsSL -o "${WORK}/${ASSET}" "${BASE}/${ASSET}"
curl -fsSL -o "${WORK}/checksums.txt" "${BASE}/registry_${VER}_checksums.txt"

echo "== verifying the download =="
EXPECTED="$(grep " ${ASSET}\$" "${WORK}/checksums.txt" | awk '{print $1}')"
ACTUAL="$(sha256sum "${WORK}/${ASSET}" | awk '{print $1}')"
[ -n "$EXPECTED" ] || { echo "no checksum published for ${ASSET} — refusing to run it" >&2; exit 1; }
if [ "$EXPECTED" != "$ACTUAL" ]; then
  echo "CHECKSUM MISMATCH — refusing to run" >&2
  echo "  expected $EXPECTED" >&2
  echo "  actual   $ACTUAL" >&2
  exit 1
fi
echo "   sha256 ${ACTUAL} OK"

tar -xzf "${WORK}/${ASSET}" -C "$WORK"
PUB="${WORK}/mcp-publisher"
[ -x "$PUB" ] || PUB="${WORK}/mcp-publisher.exe"

echo
echo "== what is listed now =="
curl -fsSL "https://registry.modelcontextprotocol.io/v0.1/servers?search=cybercentry" |
  grep -o '"name":"[^"]*"' | sort -u || true

echo
echo "== validating server.json =="
"$PUB" validate

echo
echo "== logging in (DNS proof) =="
MCP_PRIVATE_KEY="$(openssl pkey -in "$KEY" -noout -text | sed -n '/priv:/,/pub:/p' | sed '1d;$d' | tr -d ' :\n')" \
  "$PUB" login dns --domain "$DOMAIN"

echo
echo "== publishing =="
"$PUB" publish

echo
echo "== verifying it is live =="
sleep 3
curl -fsSL "https://registry.modelcontextprotocol.io/v0.1/servers?search=cybercentry" |
  grep -o '"description":"[^"]*"' | sort -u
