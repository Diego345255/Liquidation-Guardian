"use client";

import { createConfig, http } from "wagmi";
import { defineChain } from "viem";
import { getDefaultWallets } from "@rainbow-me/rainbowkit";

export const coston2 = defineChain({
  id: 114,
  name: "Coston2",
  network: "coston2",
  nativeCurrency: {
    name: "C2FLR",
    symbol: "C2FLR",
    decimals: 18,
  },
  rpcUrls: {
    default: { http: ["https://coston2-api.flare.network/ext/C/rpc"] },
    public: { http: ["https://coston2-api.flare.network/ext/C/rpc"] },
  },
  blockExplorers: {
    default: {
      name: "Coston2 Explorer",
      url: "https://coston2-explorer.flare.network",
    },
  },
});

const { connectors } = getDefaultWallets({
  appName: "Liquidation Guardian",
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_ID!,
});

export const config = createConfig({
  chains: [coston2],
  transports: {
    [coston2.id]: http(coston2.rpcUrls.default.http[0]),
  },
  connectors,
  ssr: true,
});
