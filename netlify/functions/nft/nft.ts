import { HandlerContext, HandlerEvent } from "@netlify/functions";
import * as t from "io-ts";
import { flow, pipe } from "fp-ts/function";
import { task, taskEither as te } from "fp-ts";
import { StatusCodes } from "http-status-codes";
import { TaskEither } from "fp-ts/TaskEither";
import { Contract, ethers } from "ethers";
import abi from "../../../src/NFTPrinterABI";
import axios from "axios";
import * as dotenv from "dotenv";

dotenv.config();

const supportedNetworks = ["sepolia", "goerli", "mumbai"];

const ipfsGateway = "https://cloudflare-ipfs.com/ipfs/";

const networkToNodeUrl = (network: string): string => {
  switch (network) {
    case "goerli":
      return process.env.GOERLI_RPC_URL;
    case "sepolia":
      return process.env.SEPOLIA_RPC_URL;
    case "mumbai":
      return process.env.MUMBAI_RPC_URL;
    default:
      return process.env.SEPOLIA_RPC_URL;
  }
};

const Query = t.type({
  network: t.string,
  contractAddress: t.string,
  tokenId: t.string,
});

export type IQuery = t.TypeOf<typeof Query>;

interface INFTQuery {
  tokenId: string;
  contract: Contract;
  network: string;
}

interface IAppError {
  statusCode: StatusCodes;
}

interface INFTData {
  [key: string]: string;
  owner: string;
  tokenId: string;
  contractAddress: string;
  network: string;
}

const toQuery = (e: HandlerEvent): TaskEither<IAppError, IQuery> =>
  pipe(
    te.fromEither(Query.decode(e.queryStringParameters)),
    te.mapLeft(() => ({
      statusCode: StatusCodes.BAD_REQUEST,
      body: "Malformed query string",
    }))
  );

const toNFTQuery = ({
  network,
  contractAddress,
  tokenId,
}: IQuery): TaskEither<IAppError, INFTQuery> =>
  supportedNetworks.includes(network)
    ? te.right({
        contract: flow(
          networkToNodeUrl,
          (url) => new ethers.providers.JsonRpcProvider(url),
          (provider) => new ethers.Contract(contractAddress, abi.abi, provider)
        )(network),
        tokenId,
        network,
      })
    : te.left({
        statusCode: StatusCodes.BAD_REQUEST,
        body: "Network not supported",
      });

const toNFTData = ({
  tokenId,
  contract,
  network,
}: INFTQuery): TaskEither<IAppError, INFTData> =>
  te.tryCatch(
    async () => {
      const uri = await contract.tokenURI(tokenId);
      console.log(tokenId, contract.address, network);
      const owner = await contract.ownerOf(tokenId);
      const cid = uri.replace("ipfs://", "");
      const metadataUri = ipfsGateway + cid;
      const { data } = await axios.get(metadataUri);
      const base = {
        ...data,
        owner,
        tokenId,
        contractAddress: contract.address,
        network,
      };

      // @Todo break into it's own function
      try {
        const weiPrice = await contract.getListing(tokenId);
        const price = ethers.utils.formatEther(weiPrice);
        return { ...base, price };
      } catch (e) {
        return { ...base, price: null };
      }
    },
    (e) => ({
      statusCode: StatusCodes.BAD_GATEWAY,
      body: JSON.stringify(
        "Something has went wrong on the API level. Please try again soon."
      ),
    })
  );

// Basic query string NFT lookup
// Example: http://localhost:8888/.netlify/functions/nft?network=sepolia&contractAddress=0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259&tokenId=0
const handler = async (event: HandlerEvent, context: HandlerContext) =>
  pipe(
    toQuery(event),
    te.chain(toNFTQuery),
    te.chain(toNFTData),
    te.fold(task.of, (body) =>
      task.of({
        statusCode: StatusCodes.OK,
        body: JSON.stringify(body),
      })
    )
  )();

export { handler };
