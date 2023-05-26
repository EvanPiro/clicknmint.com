// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0x1A2D93512E47fd49213957714F136E2a78eC4f45",
    scanURL: "https://goerli.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0xDC62D45d5C96CAFB749b5D46624E30d252C3ddb5",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "mumbai",
    printNFTAddress: "0x6fD61bD183a8A06b0bEF2a293Cd1FC69AcC6b38b",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
