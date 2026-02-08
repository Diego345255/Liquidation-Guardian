"use client";

import { useReadContract } from "wagmi";
import { oracleAbi, ORACLE_ADDRESS } from "@/lib/contracts/oracle";

export default function TestPrice() {
  const { data, error, isLoading } = useReadContract({
    address: ORACLE_ADDRESS,
    abi: oracleAbi,
    functionName: "getPrice",
    args: ["FLR/USD"],
  }) as {
    data: readonly [bigint, bigint] | undefined;
    error: Error | null;
    isLoading: boolean;
  };

  if (isLoading) return <div>Loading price…</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!data) return <div>No data returned</div>;

  const [price18, timestamp] = data;

  return (
    <div style={{ padding: 20 }}>
      <h1>Oracle Price Test</h1>
      <p>Price (18 decimals): {price18.toString()}</p>
      <p>Timestamp: {timestamp.toString()}</p>
    </div>
  );
}
