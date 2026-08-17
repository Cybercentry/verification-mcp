# Cybercentry MCP Server

Pay-per-call security verification for AI agents: wallets, tokens, contracts, dApps, agents and more.

Nothing to install. This is a **remote** MCP server — connect to the URL and the tools appear.

| | |
|---|---|
| **Endpoint** | `https://centry.cybercentry.co.uk/api/mcp` |
| **Transport** | `streamable-http` |
| **Registry** | [`uk.co.cybercentry/verification`](https://registry.modelcontextprotocol.io/v0.1/servers?search=cybercentry) |
| **Website** | https://centry.cybercentry.co.uk |

## Connect

### Claude (Desktop or claude.ai)

Remote servers are added as **connectors**, not through `claude_desktop_config.json` — that file is for local servers that run a command.

1. Settings → **Connectors**
2. **Add** → **Add custom connector**
3. Paste `https://centry.cybercentry.co.uk/api/mcp`

### Other clients

Anything that speaks MCP over streamable HTTP can connect. Point it at:

```
https://centry.cybercentry.co.uk/api/mcp
```

Check your client's own documentation for where a remote MCP server URL goes — some use a settings pane, some a config file. If yours takes a config file, the field is the server URL rather than a command.

## Tools

Twelve tools. Two are free and need no payment, credentials or account:

| Tool | What it does |
|---|---|
| `list_services` | The catalogue: every verification, its inputs and its price |
| `recent_exploits` | Live exploit feed, curated from DefiLlama |

The other ten are paid, at $1.00 per call:

| Tool | What it verifies |
|---|---|
| `wallet_verification` | Sanctions screening and risk scoring across 35 EVM chains |
| `base_token_verification` | Base B20 tokens: honeypots, freeze-and-seize, pause, impersonation |
| `ethereum_token_verification` | Ethereum token due diligence |
| `solidity_code_verification` | Solidity source, for known vulnerability classes |
| `web_application_verification` | Live site and dApp frontend scan |
| `openclaw_ai_agent_verification` | An agent's configuration: auth gaps, prompt-injection exposure, unsafe permissions |
| `media_content_verification` | C2PA provenance and content authenticity |
| `private_data_verification` | Zero-knowledge proof over a payload, without revealing it |
| `quantum_cryptography_verification` | Quantum-resistant encryption of a payload |
| `cyber_security_consultant` | Advisory answers grounded in a security body of knowledge |

Wallet and web application verification return a job immediately and fill in as findings arrive; both can take up to three minutes. The rest return in under ten seconds.

## Paying

No API keys. No accounts. Two ways to pay for the ten paid tools:

**x402** — the client is told the price, pays in USDC, and retries. Automatic in clients that support it.

```
Base    eip155:8453   USDC
Solana  mainnet       USDC
```

**Subscription token** — for clients that do not speak x402 yet. Pass `subscription_token` as a tool argument, or send it as the `x-subscription-token` header.

A paid call runs the verification *before* it settles, so a call that fails is never charged.

## Standards

The interfaces these services implement were specified in public:

- [ERC-8126](https://eips.ethereum.org/EIPS/eip-8126) — AI Agent Verification (Final)
- [ERC-8196](https://eips.ethereum.org/EIPS/eip-8196) — AI Agent Authenticated Wallet (Final)
- [ERC-8376](https://github.com/ethereum/ERCs/pull/1942) — Token Launch Abuse Detection and Remediation (open pull request)

## Links

- Endpoint — https://centry.cybercentry.co.uk/api/mcp
- Site and full catalogue — https://centry.cybercentry.co.uk
- How it works — https://centry.cybercentry.co.uk/guide
- Standards — https://centry.cybercentry.co.uk/standards
- OpenAPI — https://centry.cybercentry.co.uk/openapi.json

---

Cybercentry Limited
