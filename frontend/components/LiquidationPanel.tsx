"use client";

type Props = {
  healthFactor: number | null;
  collateralETH: number;
  debtUSDC: number;
  onSimulateLiquidation: () => void;
};

export default function LiquidationPanel({
  healthFactor,
  collateralETH,
  debtUSDC,
  onSimulateLiquidation,
}: Props) {
  const canLiquidate = healthFactor !== null && healthFactor < 1;

  return (
    <div className="p-4 border rounded-lg flex flex-col gap-3">
      <h2 className="font-semibold text-lg">Liquidation Status</h2>

      <p>Collateral: {collateralETH} ETH</p>
      <p>Debt: {debtUSDC} USDC</p>

      {canLiquidate ? (
        <div className="flex flex-col gap-2">
          <p className="text-red-600 font-semibold">
            Position is liquidatable!
          </p>
          <button
            className="bg-red-600 text-white px-4 py-2 rounded"
            onClick={onSimulateLiquidation}
          >
            Simulate Liquidation
          </button>
        </div>
      ) : (
        <p className="text-green-600 font-semibold">Position is safe.</p>
      )}
    </div>
  );
}
