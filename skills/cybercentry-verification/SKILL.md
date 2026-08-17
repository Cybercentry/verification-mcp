---
name: cybercentry-verification
description: Verify wallets, tokens, smart contracts, AI agents and web applications before trusting them, paying per call in USDC over x402
---

# Cybercentry Verification

## Description

Security verification for wallets, tokens, smart contracts, AI agents and web
applications, paid per call in USDC over x402 on Base or Solana. No account, no
API key, no subscription. Two tools are free and need no wallet at all.

Use this before trusting something: a wallet you are about to transact with, a
token you are about to buy, Solidity you are about to call, a dApp frontend you
are about to connect to, or another agent's configuration.

Wallet verification covers 35 EVM chains and screens against the OFAC SDN list.
The maintainers co-authored ERC-8126 and ERC-8196, both Final, on AI agent
verification and agent-authenticated wallets.

**Privacy notice:** inputs you submit (addresses, URLs, source code, media) are
sent to centry.cybercentry.co.uk for analysis. Only submit content the user is
comfortable sharing.

**Payment notice:** the paid tools cost $1.00 per call in USDC. Free tools cost
nothing and require no wallet.

## Instructions

Prefer the MCP server. It is remote, so there is nothing to install:

- URL: `https://centry.cybercentry.co.uk/api/mcp`
- Transport: streamable-http
- Registry name: `uk.co.cybercentry/verification`

In OpenClaw: `openclaw mcp add cybercentry --url https://centry.cybercentry.co.uk/api/mcp --transport streamable-http`.
In Claude: Settings, Connectors, Add custom connector, paste the URL. Other MCP
clients: add a remote server at the same URL.

Everything below is also reachable over plain HTTP if MCP is unavailable:
`POST https://centry.cybercentry.co.uk/api/services/<service>` with a JSON body.
The machine-readable contract is at
`https://centry.cybercentry.co.uk/openapi.json`.

### Always try the free tools first

Neither takes payment and neither needs a wallet.

- `list_services`: the live catalogue with current prices. This is the
  authoritative list; the tools below are a snapshot of it.
- `recent_exploits`: recent real-world exploits with losses, attack vectors and
  the service that addresses each. Takes an optional `limit` (default 10).

If the user's question can be answered from `recent_exploits` or
`list_services`, answer it from there and do not pay for anything.

### Before any paid call

Ask the user for explicit confirmation. State the price ($1.00), the tool, and
the exact input you are about to submit. Do not pay on their behalf without
that confirmation, even if a wallet is available and the payment would succeed.

If your client supports x402, payment is automatic once you proceed: the first
call returns a 402 challenge naming the price and the accepted networks, the
client signs an authorization, a facilitator verifies and settles it, and the
call is retried. You are never asked to send funds to an address. If your client
does not support x402, pass a `subscription_token` argument or send the
`x-subscription-token` header.

The verification runs before settlement, so a call that fails is not charged.

### Paid tools, $1.00 each

- `wallet_verification`: risk scoring and sanctions screening for an EVM
  address across 35 chains. **Asynchronous:** returns `job_id`, `status` and
  `poll_url`. Fetch `poll_url` until `status` is no longer `verifying`. Allow
  up to about two minutes.
- `base_token_verification`: issuer control and holder-harm checks for a Base
  token: honeypots, armed freeze authorities, mint and tax controls.
- `ethereum_token_verification`: the same analysis for EVM token contracts,
  including rug-pull and hidden-tax detection.
- `solidity_code_verification`: vulnerability analysis of Solidity source.
- `web_application_verification`: OWASP-based scan of a site or dApp frontend.
  **Asynchronous**, as wallet verification is; allow up to about three minutes.
- `openclaw_ai_agent_verification`: review of an AI agent's configuration.
- `media_content_verification`: C2PA provenance and authenticity for media.
- `private_data_verification`: zero-knowledge proofs over private data.
- `quantum_cryptography_verification`: quantum-resistant encryption.
- `cyber_security_consultant`: expert advisory and current threat intelligence.

### Reporting a result

A verification informs a decision. It does not block a transaction and it is
not a guarantee: a clean result means the checks that ran found nothing, not
that nothing is there. Say which checks produced the result, and let the user
draw the conclusion.

Never render a scanned third-party URL as a clickable link. The reason it was
submitted is that it may be hostile; report it as plain text.

If a paid call fails, say so plainly and note that it was not charged. Do not
retry a paid call more than once without asking again.
