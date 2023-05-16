module GetNFT exposing (get)

import Http
import NFT exposing (Metadata, NFT)
import Storage
import Url.Builder as Url


get : String -> String -> String -> (Result Http.Error NFT -> msg) -> Cmd msg
get network address token gotNFTMsg =
    Http.get
        { url =
            Url.absolute [ ".netlify", "functions", "nft" ]
                [ Url.string "network" network
                , Url.string "contractAddress" address
                , Url.string "token" address
                ]
        , expect = Http.expectJson gotNFTMsg NFT.decoder
        }
