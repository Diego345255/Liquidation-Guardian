import { JsonRpcProvider } from "ethers";

export class FlareClient {
  provider: JsonRpcProvider;

  constructor(rpcUrl: string) {
    this.provider = new JsonRpcProvider(rpcUrl);
  }

  async getFtsoPrice(feedId: string) {
    return this.provider.send("ftso_getFeedValue", [feedId]);
  }
}

