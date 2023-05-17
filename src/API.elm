module API exposing (getNFT)

import Http
import NFT exposing (Metadata, NFT)
import Storage
import Url.Builder as Url


getNFT : String -> String -> String -> (Result Http.Error NFT -> msg) -> Cmd msg
getNFT network address token gotNFTMsg =
    Http.get
        { url =
            Url.absolute [ ".netlify", "functions", "nft" ]
                [ Url.string "network" network
                , Url.string "contractAddress" address
                , Url.string "tokenId" token
                ]
        , expect = Http.expectJson gotNFTMsg NFT.decoder
        }
