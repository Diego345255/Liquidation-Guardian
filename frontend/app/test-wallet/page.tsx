"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

export default function TestWallet() {
  const { address, isConnected } = useAccount();

  return (
    <div style={{ padding: 20 }}>
      <ConnectButton />

      {isConnected && (
        <div style={{ marginTop: 20 }}>
          <strong>Connected:</strong> {address}
        </div>
      )}
    </div>
  );
}
