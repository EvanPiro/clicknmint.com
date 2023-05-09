// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0x25b6364A5979e0e7C2ca3124d3b5d0A365EF1259",
    scanURL: "https://sepolia.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "polygon",
    printNFTAddress: "0x7Bf185C1Cd8d9608307f22cFD4ef598772Be3413",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
