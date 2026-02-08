import { useMemo } from "react";
import { FlareClient } from "./flareClient";

export function useFlare() {
  return useMemo(() => {
    return new FlareClient(process.env.NEXT_PUBLIC_FLARE_RPC!);
  }, []);
}

