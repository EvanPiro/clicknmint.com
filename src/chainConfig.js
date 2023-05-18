// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0xc5E452E9F33D8480554d933E0DDf6272209DAA07",
    scanURL: "https://sepolia.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0x27da9ADd025d554387f1e2EBAf59CE6Ee1Aa8d83",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "polygon",
    printNFTAddress: "0x6fD61bD183a8A06b0bEF2a293Cd1FC69AcC6b38b",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
