# Liquidation Guardian — Coston2 FTSO Edition

Liquidation Guardian is a real‑time risk‑monitoring dashboard built on the Flare ecosystem.  
It calculates collateral health, simulates liquidation events, and fetches "live price feeds directly from the Coston2 FTSO Price Provider" using Wagmi + Viem.

This version is fully functional end‑to‑end on "Coston2", with real oracle data, no mocks, and no fallbacks.

---

## Features

### Live FTSO Price Feeds (Coston2)
Reads real‑time prices from the Coston2 FTSO Price Provider using:

- `getCurrentPriceWithDecimals(bytes32)`
- ETH/USD feed
- USDC/USD feed

### Real‑Time Health Factor Calculation
The dashboard computes a dynamic health factor based on:

- Collateral value (ETH)
- Debt value (USDC)
- Live oracle prices

### Liquidation Simulation
A one‑click simulation shows how a liquidation event affects:

- Collateral
- Debt
- Health factor

### Clean, UI
Built with:

- Next.js (App Router)
- RainbowKit + Wagmi
- Viem
- TailwindCSS

---

## Architecture Overview

The app uses:

- **Wagmi** for wallet + public client
- **Viem** for contract reads
- **Coston2 chain config** for RPC + chain metadata
- **FTSO Price Provider contract** for oracle data
- **React state** for collateral, debt, and health factor

All price reads are performed client‑side using:

```ts
client.readContract({
  address: FTSO_ADDRESS,
  abi: ftsoAbi,
  functionName: "getCurrentPriceWithDecimals",
  args: [ETH_FEED_ID],
});
Installation

Clone the repo and install dependencies:

npm install

Create a .env.local file:

NEXT_PUBLIC_WALLETCONNECT_ID=your_project_id_here

Running the App

Start the development server:

npm run dev

Then open:

http://localhost:3000

Coston2 FTSO Integration

This project uses the correct, working Coston2 FTSO Price Provider address and feed IDs.

The app gracefully handles:

    Successful price reads

    Reverts (if a feed is temporarily unavailable)

    UI updates based on live data

Project Structure
── backend
│   ├── broadcast
│   ├── cache
│   ├── foundry.toml
│   ├── lib
│   ├── out
│   ├── script
│   ├── src
│   └── test
├── foundry.lock
├── frontend
│   ├── abi
│   ├── app
│   ├── components
│   ├── eslint.config.mjs
│   ├── lib
│   ├── next.config.ts
│   ├── next-env.d.ts
│   ├── node_modules
│   ├── package.json
│   ├── package-lock.json
│   ├── postcss.config.mjs
│   ├── public
│   ├── README.md
│   └── tsconfig.json
├── lib
│   ├── forge-std
│   └── openzeppelin-contracts
├── LICENSE
└── README.md

Liquidation Logic

The health factor is computed as:
Code

HF = (collateral_value * liquidation_threshold) / debt_value

The UI updates automatically when:

    Prices change

    Collateral changes

    Debt changes

Future Enhancements

    Multi‑asset collateral support

    Historical price charts

    Liquidation history

    Multi‑chain support (Songbird, Flare mainnet)

    Smart contract integration for on‑chain liquidation

Summary
Liquidation Guardian demonstrates:

    Real‑time risk monitoring

    Live Coston2 FTSO oracle integration

    Health factor modeling

    Liquidation simulation

    Clean, production‑ready architecture

