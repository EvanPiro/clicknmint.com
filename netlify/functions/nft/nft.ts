import { HandlerContext, HandlerEvent } from "@netlify/functions";
import * as t from "io-ts";
import { pipe } from "fp-ts/function";
import { task, taskEither as te } from "fp-ts";
import { StatusCodes } from "http-status-codes";
import { TaskEither } from "fp-ts/TaskEither";
import { ethers } from "ethers";
import abi from "../../../src/NFTPrinterABI";
import axios from "axios";
import * as dotenv from "dotenv";

dotenv.config();

const sepoliaRpcUrl = process.env.SEPOLIA_RPC_URL;

const contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8";

const supportedNetworks = ["sepolia"];

const ipfsGateway = "https://cloudflare-ipfs.com/ipfs/";

const NFTQuery = t.partial({
  network: t.string,
  contractAddress: t.string,
  tokenId: t.string,
});

export type INFTQuery = t.TypeOf<typeof NFTQuery>;

interface IAppError {
  statusCode: StatusCodes;
}

interface IRPCRes {
  data: string;
}

const toQuery = (e: HandlerEvent): TaskEither<IAppError, INFTQuery> =>
  pipe(
    te.fromEither(NFTQuery.decode(e.queryStringParameters)),
    te.mapLeft(() => ({
      statusCode: StatusCodes.BAD_REQUEST,
      body: "Malformed query string",
    }))
  );

const validateNetwork = (q: INFTQuery): TaskEither<IAppError, INFTQuery> =>
  supportedNetworks.includes(q.network)
    ? te.right(q)
    : te.left({
        statusCode: StatusCodes.BAD_REQUEST,
        body: "Network not supported",
      });

const toRPCRes = (q: INFTQuery): TaskEither<IAppError, IRPCRes> =>
  te.tryCatch(
    async () => {
      const provider = new ethers.providers.JsonRpcProvider(sepoliaRpcUrl);
      const contract = new ethers.Contract(contractAddress, abi.abi, provider);
      const uri = await contract.tokenURI(q.tokenId);
      const cid = uri.replace("ipfs://", "");
      const metadataUri = ipfsGateway + cid;
      const { data } = await axios.get(metadataUri);
      return {
        data: JSON.stringify(data),
      };
    },
    () => ({
      statusCode: StatusCodes.BAD_GATEWAY,
      body: "Data retrieve issues on our end.",
    })
  );

// Basic query string NFT lookup
// Example: http://localhost:8888/.netlify/functions/nft?network=sepolia&contractAddress=0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259&tokenId=0
const handler = async (event: HandlerEvent, context: HandlerContext) =>
  pipe(
    toQuery(event),
    te.chain(validateNetwork),
    te.chain(toRPCRes),
    te.fold(task.of, (body) =>
      task.of({
        statusCode: StatusCodes.OK,
        body: JSON.stringify(body),
      })
    )
  )();

export { handler };
