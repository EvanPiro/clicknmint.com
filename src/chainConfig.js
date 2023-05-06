// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0xd3c78aa2417a8e349243b50aac2d43457367d76e",
    scanURL: "https://sepolia.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0xd00430a066c3dacea692930023d74376fe64e95f",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "polygon",
    printNFTAddress: "0x03ad98fa8c1a55ee0b2343c7c05d71ad58f40063",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
