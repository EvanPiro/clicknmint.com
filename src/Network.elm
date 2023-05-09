-- WIP Experimental
-- Might be best to leave the configuration up to the build and current wallet network settings so
-- that Elm can manage the model agnostic of the network or contract.
module Network exposing (chainIdToConfig)


type Network
    = Goerli
    | Sepolia
    | Mumbai

type alias Config =
            { name: String
            , nftPrinterAddress : String
            , scanUrl : String
            }


chainIdToConfig : String -> Maybe Config
chainIdToConfig model =
    case model of
                "5" -> Just {name = "goerli", nftPrinterAddress = "0xd3c78aa2417a8e349243b50aac2d43457367d76e", scanUrl = "https://sepolia.etherscan.io"}
                "11155111" -> Just {name = "sepolia", nftPrinterAddress = "0xd00430a066c3dacea692930023d74376fe64e95f", scanUrl = "https://sepolia.etherscan.io"}
                "80001" -> Just {name = "polygon", nftPrinterAddress = "0x03ad98fa8c1a55ee0b2343c7c05d71ad58f40063", scanUrl = "https://mumbai.polygonscan.com"}
                  _ -> Nothing

