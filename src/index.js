import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import { ethers } from "ethers";
import abi from "./NFTPrinterABI";
import { config, isSupported } from "./chainConfig";
import * as dotenv from "dotenv";

dotenv.config();

const apiKey = process.env.ELM_APP_API_KEY;

let tokenIdCounter = 0;
let tokenEnd = false;

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: apiKey,
});

async function getNft(tokenId) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  provider.send("eth_requestAccounts", []);

  console.log(provider);
  const { chainId } = await provider.getNetwork();
  console.log(chainId);
  const signer = await provider.getSigner();
  const networkConfig = config[chainId];
  const contract = new ethers.Contract(
    networkConfig.printNFTAddress,
    abi.abi,
    provider
  ).connect(signer);
  console.log(contract);
  const nftUri = await contract.tokenURI(tokenId);
  console.log(nftUri);
  const scanUrl = `${networkConfig.scanURL}/${networkConfig.printNFTAddress}?a=${tokenId}`;
  return {
    nftUri,
    scanUrl,
  };
}

async function getNftCatchError() {
  console.log("called getNftCatchError");
  if (!tokenEnd) {
    try {
      console.log("inside try");
      const res = await getNft(tokenIdCounter);
      console.log("after getNFT");

      app.ports.nftFound.send([res.nftUri, res.scanUrl]);
      tokenIdCounter++;
    } catch (error) {
      console.log(error);
      tokenEnd = true;
      if (error.reason === "ERC721: invalid token ID") {
        app.ports.nftFound.send(null);
      } else {
        app.ports.walletStatusNotFound.send("");
      }
    }
  }
}

app.ports.detectWallet.subscribe(function () {
  getNftCatchError();
});

window.onscroll = function (e) {
  let documentHeight = document.body.scrollHeight;
  let currentScroll = window.scrollY + window.innerHeight;
  // When the user is [modifier]px from the bottom, fire the event.
  let modifier = 10;

  if (currentScroll + modifier > documentHeight) {
    console.log("You are at the bottom!");
    setTimeout(function () {
      getNftCatchError();
    }, 500);
  }
};

app.ports.mintRequested.subscribe(async function (nftUri) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const { chainId } = await provider.getNetwork();
  if (isSupported(chainId)) {
    const signer = provider.getSigner();
    const networkConfig = config[chainId];
    const contract = new ethers.Contract(
      networkConfig.printNFTAddress,
      abi.abi,
      provider
    ).connect(signer);

    mint(networkConfig, signer, contract, provider, nftUri);
  } else {
    app.ports.walletError.send(
      `Network with chain id ${chainId} is not supported. Please switch to one of the following supported networks: mumbai, goerli, sepolia.`
    );
  }
});

function mint(networkConfig, signer, contract, provider, nftUri) {
  provider.send("eth_requestAccounts", []).then(async () => {
    contract
      .printNFT(await signer.getAddress(), nftUri, {
        value: ethers.utils.parseUnits("0.01", "ether"),
      })
      .then(async (res) => {
        const txnUrl = `${networkConfig.scanURL}/tx/${res.hash}`;
        const waitRes = await res.wait();
        const tokenIdHex = waitRes.events.filter((e) =>
          e.hasOwnProperty("args")
        )[0].args.tokenId;

        const tokenId = tokenIdHex.toNumber().toString();

        app.ports.mintRequestSucceeded.send({
          tokenId,
          txnUrl,
          contractAddress: networkConfig.printNFTAddress,
        });
      })
      .catch((err) => {
        console.log(err);
        app.ports.mintRequestFailed.send("");
      });
  });
}

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
