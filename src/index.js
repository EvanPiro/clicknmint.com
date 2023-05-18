import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import { ethers } from "ethers";
import abi from "./NFTPrinterABI";
import { config, isSupported } from "./chainConfig";
import * as dotenv from "dotenv";

dotenv.config();

const apiKey = process.env.ELM_APP_API_KEY;

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: apiKey,
});

{
  // The "any" network will allow spontaneous network changes
  const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
  provider.on("network", (newNetwork, oldNetwork) => {
    // When a Provider makes its initial connection, it emits a "network"
    // event with a null oldNetwork along with the newNetwork. So, if the
    // oldNetwork exists, it represents a changing network
    if (oldNetwork) {
      window.location.reload();
    }
  });
}

app.ports.detectEthereum.subscribe(async function () {
  app.ports.detectEthereumRes.send(!!window.ethereum);
});

app.ports.detectWallet.subscribe(async function () {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const { chainId } = await provider.getNetwork();
    const network = config[chainId].name;
    const signer = await provider.getSigner();
    const address = await signer.getAddress();
    app.ports.walletFound.send([network, address]);
  } catch (e) {
    app.ports.walletNotFound.send("");
  }
});

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
    app.ports.networkError.send(
      `Network with chain id ${chainId} is not supported. Please switch to one of the following supported networks: mumbai, goerli, sepolia.`
    );
  }
});

app.ports.setListing.subscribe(async function (nft) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const { chainId } = await provider.getNetwork();
  if (config[chainId].name === nft.network) {
    const signer = provider.getSigner();
    const networkConfig = config[chainId];
    const contract = new ethers.Contract(
      nft.contractAddress,
      abi.abi,
      provider
    ).connect(signer);

    setListing(networkConfig, signer, contract, provider, nft);
  } else {
    app.ports.networkError.send(
      `Please switch network to ${nft.network} to set listing price`
    );
  }
});

app.ports.buyListing.subscribe(async function (nft) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const { chainId } = await provider.getNetwork();
  if (config[chainId].name === nft.network) {
    const signer = provider.getSigner();
    const networkConfig = config[chainId];
    const contract = new ethers.Contract(
      nft.contractAddress,
      abi.abi,
      provider
    ).connect(signer);

    buyListing(networkConfig, signer, contract, provider, nft);
  } else {
    app.ports.networkError.send(
      `Please switch network to ${nft.network} to set listing price`
    );
  }
});

app.ports.removeListing.subscribe(async function (nft) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const { chainId } = await provider.getNetwork();
  if (config[chainId].name === nft.network) {
    const signer = provider.getSigner();
    const networkConfig = config[chainId];
    const contract = new ethers.Contract(
      nft.contractAddress,
      abi.abi,
      provider
    ).connect(signer);

    removeListing(networkConfig, signer, contract, provider, nft);
  } else {
    app.ports.networkError.send(
      `Please switch network to ${nft.network} to remove listing`
    );
  }
});

function setListing(networkConfig, signer, contract, provider, nft) {
  provider.send("eth_requestAccounts", []).then(async () => {
    contract
      .setListing(nft.tokenId, ethers.utils.parseUnits(nft.price, "ether"))
      .then(async (res) => {
        await res.wait();
        app.ports.setListingRes.send("success");
      })
      .catch((err) => {
        app.ports.setListingRes.send(null);
      });
  });
}

function buyListing(networkConfig, signer, contract, provider, nft) {
  provider.send("eth_requestAccounts", []).then(async () => {
    contract
      .buyListing(nft.tokenId, {
        value: ethers.utils.parseUnits(nft.price, "ether"),
      })
      .then(async (res) => {
        await res.wait();
        app.ports.buyListingRes.send("success");
      })
      .catch((err) => {
        app.ports.buyListingRes.send(null);
      });
  });
}

function removeListing(networkConfig, signer, contract, provider, nft) {
  provider.send("eth_requestAccounts", []).then(async () => {
    contract
      .removeListing(nft.tokenId)
      .then(async (res) => {
        await res.wait();
        app.ports.removeListingRes.send("success");
      })
      .catch((err) => {
        app.ports.removeListingRes.send(null);
      });
  });
}

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
          network: networkConfig.name,
          owner: signer.getAddress(),
        });
      })
      .catch((err) => {
        app.ports.mintRequestFailed.send("");
      });
  });
}

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
