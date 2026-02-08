export function computeHealthFactor({
  collateralValueUSD,
  debtValueUSD,
  liquidationThreshold = 0.8, // 80%
}: {
  collateralValueUSD: number;
  debtValueUSD: number;
  liquidationThreshold?: number;
}) {
  if (debtValueUSD === 0) return Infinity;

  return (collateralValueUSD * liquidationThreshold) / debtValueUSD;
}
