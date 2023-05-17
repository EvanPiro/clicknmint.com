// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0x82873514B4017d08c3932c4ce8A28A6f596F2050",
    scanURL: "https://sepolia.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0x0BfDe5F9cE572F10Cc4073c70788604E49a6ddDC",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "polygon",
    printNFTAddress: "0xE3E8985f486A2Ed8cE7564FefA6F7594De8D10eF",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
