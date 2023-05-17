import { HandlerContext, HandlerEvent } from "@netlify/functions";
import * as t from "io-ts";
import { pipe } from "fp-ts/function";
import { task, taskEither as te } from "fp-ts";
import { StatusCodes } from "http-status-codes";
import { TaskEither } from "fp-ts/TaskEither";
import { Contract, ethers } from "ethers";
import abi from "../../../src/NFTPrinterABI";
import axios from "axios";
import * as dotenv from "dotenv";

dotenv.config();

const sepoliaRpcUrl = process.env.SEPOLIA_RPC_URL;

const contractAddress = "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8";

const supportedNetworks = ["sepolia"];

const ipfsGateway = "https://cloudflare-ipfs.com/ipfs/";

const provider = new ethers.providers.JsonRpcProvider(sepoliaRpcUrl);
const nftContract = new ethers.Contract(contractAddress, abi.abi, provider);

const NFTQuery = t.partial({
  network: t.string,
  contractAddress: t.string,
  tokenId: t.string,
});

export type INFTQuery = t.TypeOf<typeof NFTQuery>;

interface IAppError {
  statusCode: StatusCodes;
}

interface INFTData {
  [key: string]: string;
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

const toNFTData =
  (contract: Contract) =>
  (q: INFTQuery): TaskEither<IAppError, INFTData> =>
    te.tryCatch(
      async () => {
        const uri = await contract.tokenURI(q.tokenId);
        const owner = await contract.ownerOf(q.tokenId);
        const cid = uri.replace("ipfs://", "");
        const metadataUri = ipfsGateway + cid;
        const { data } = await axios.get(metadataUri);
        return {
          ...data,
          owner,
          ...q,
        };
      },
      () => ({
        statusCode: StatusCodes.BAD_GATEWAY,
        body: "Data retrieval issues on our end.",
      })
    );

const checkForPrice =
  (contract: Contract) =>
  (d: INFTData): TaskEither<IAppError, INFTData> =>
    te.tryCatch(
      async () => {
        console.log("check for price began");
        // Because contract will error on tokenId not found, allow for not found.
        try {
          const price = await contract.getListing(d.tokenId);
          return {
            ...d,
            price,
          };
        } catch (e) {
          return {
            ...d,
            price: null,
          };
        }
      },
      (e) => ({
        statusCode: StatusCodes.BAD_GATEWAY,
        body: "Data retrieval issues on our end.",
      })
    );

// Basic query string NFT lookup
// Example: http://localhost:8888/.netlify/functions/nft?network=sepolia&contractAddress=0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259&tokenId=0
const handler = async (event: HandlerEvent, context: HandlerContext) =>
  pipe(
    toQuery(event),
    te.chain(validateNetwork),
    te.chain(toNFTData(nftContract)),
    te.chain(checkForPrice(nftContract)),
    te.fold(task.of, (body) =>
      task.of({
        statusCode: StatusCodes.OK,
        body: JSON.stringify(body),
      })
    )
  )();

export { handler };
