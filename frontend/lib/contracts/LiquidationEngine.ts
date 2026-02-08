import LiquidationEngineJson from "@/abi/LiquidationEngine.json";

export const liquidationEngineAbi = LiquidationEngineJson.abi;

export const LIQUIDATION_ENGINE_ADDRESS =
  process.env.NEXT_PUBLIC_LIQUIDATION_ENGINE_ADDRESS!;
