// Chain ID to network and contract config.
// (see https://chainlist.org/)
export const config = {
  5: {
    name: "goerli",
    printNFTAddress: "0xd90cE35A4befCD62d767044F26c120C0979d2d22",
    scanURL: "https://sepolia.etherscan.io",
  },
  11155111: {
    name: "sepolia",
    printNFTAddress: "0x394a4aa08cf1d102db582497db13b9e85c3a4762",
    scanURL: "https://sepolia.etherscan.io",
  },
  80001: {
    name: "polygon",
    printNFTAddress: "0x2fd170d774085db9c4fcbb215e13bfc3b00690c3",
    scanURL: "https://mumbai.polygonscan.com",
  },
};

export const isSupported = (chainId) =>
  Object.keys(config).includes(chainId.toString());
