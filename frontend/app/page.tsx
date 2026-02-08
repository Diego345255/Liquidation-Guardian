"use client";

import { useEffect, useState } from "react";
import { usePublicClient } from "wagmi";
import { parseAbi, toHex } from "viem";
import HealthFactorCard from "../components/HealthFactorCard";
import LiquidationPanel from "../components/LiquidationPanel";
import { computeHealthFactor } from "../lib/healthFactor";

// Expected FTSO Price Provider on Coston2
const FTSO_ADDRESS = "0xC4e9c78EA53db782E28f28Fdf80BaF59336B304d";

// ABI for FTSO price reads
const ftsoAbi = parseAbi([
  "function getFeedsByIdInWei(bytes21[] symbol) view returns (uint256[] values, uint64 timestamp)"
]);

// Feed IDs
const ETH = "0x01" + toHex("ETH/USD", { size: 20 }).slice(2) as `0x${string}`;
const USDC = "0x01" + toHex("USDC/USD", { size: 20 }).slice(2) as `0x${string}`;

export default function Home() {
  const client = usePublicClient();   // <-- may be undefined during SSR

  const [ethPrice, setEthPrice] = useState<number | null>(null);
  const [usdcPrice, setUsdcPrice] = useState<number | null>(null);

  const [collateralETH, setCollateralETH] = useState(1);
  const [debtUSDC, setDebtUSDC] = useState(1000);

  const [healthFactor, setHealthFactor] = useState<number | null>(null);

  // Load prices from Coston2 FTSO
  useEffect(() => {
    if (!client) return; // <-- FIX: prevents undefined access

    async function loadPrices() {
      try {
        // ETH/USD
        const [[ethValue], ] = await client!.readContract({
          address: FTSO_ADDRESS,
          abi: ftsoAbi,
          functionName: "getFeedsByIdInWei",
          args: [[ETH]],
        });

        setEthPrice(Number(ethValue) / 10 ** 18);

        // USDC/USD
        const [[usdcValue], ] = await client!.readContract({
          address: FTSO_ADDRESS,
          abi: ftsoAbi,
          functionName: "getFeedsByIdInWei",
          args: [[USDC]],
        });

        setUsdcPrice(Number(usdcValue) / 10 ** 18);
      } catch (err) {
        console.error("FTSO read error:", err);
      }
    }

    loadPrices();
  }, [client]);

  // Recompute health factor
  useEffect(() => {
    if (ethPrice == null || usdcPrice == null) return;

    const collateralValueUSD = collateralETH * ethPrice;
    const debtValueUSD = debtUSDC * usdcPrice;

    const hf = computeHealthFactor({
      collateralValueUSD,
      debtValueUSD,
    });

    setHealthFactor(hf);
  }, [ethPrice, usdcPrice, collateralETH, debtUSDC]);

  // Simulate liquidation
  const handleSimulateLiquidation = () => {
    setDebtUSDC((d) => d * 0.2); // repay 80%
    setCollateralETH((c) => c * 0.9); // take 10% collateral
  };

  return (
    <main className="min-h-screen flex flex-col items-center justify-start p-8 gap-8">
      <header className="w-full flex items-center justify-between max-w-4xl">
        <h1 className="text-2xl font-bold">Liquidation Guardian (Coston2)</h1>
      </header>

      <section className="w-full max-w-4xl grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="p-4 border rounded-lg flex flex-col gap-3">
          <h2 className="font-semibold text-lg">Market & Position</h2>

          <div className="text-sm text-gray-600">
            <p>ETH Price: {ethPrice ?? "Loading..."}</p>
            <p>USDC Price: {usdcPrice ?? "Loading..."}</p>
          </div>

          <div className="mt-3 flex flex-col gap-2 text-sm">
            <label className="flex flex-col">
              <span>Collateral (ETH)</span>
              <input
                type="number"
                value={collateralETH}
                onChange={(e) => setCollateralETH(Number(e.target.value) || 0)}
                className="border rounded px-2 py-1"
              />
            </label>

            <label className="flex flex-col">
              <span>Debt (USDC)</span>
              <input
                type="number"
                value={debtUSDC}
                onChange={(e) => setDebtUSDC(Number(e.target.value) || 0)}
                className="border rounded px-2 py-1"
              />
            </label>
          </div>
        </div>

        <div className="flex flex-col gap-4">
          <HealthFactorCard healthFactor={healthFactor} />

          <LiquidationPanel
            healthFactor={healthFactor}
            collateralETH={collateralETH}
            debtUSDC={debtUSDC}
            onSimulateLiquidation={handleSimulateLiquidation}
          />
        </div>
      </section>
    </main>
  );
}
