module Storage exposing
    ( cidToFileUrl
    , cidToIpfsUri
    , nftStorageUrl
    , uploadFile
    , uploadJSON
    , uploadRespDecoder
    )

import File exposing (File)
import Http
import Json.Decode exposing (Decoder, field, string)
import Json.Encode as E


nftStorageUrl =
    "https://api.nft.storage/upload"


cidToFileUrl : String -> String
cidToFileUrl cid =
    "https://cloudflare-ipfs.com/ipfs/" ++ cid


uploadRespDecoder : Decoder String
uploadRespDecoder =
    field "value" (field "cid" string)


uploadFile : String -> (Result Http.Error String -> msg) -> File -> Cmd msg
uploadFile apiKey gotFileMsg file =
    Http.request
        { method = "POST"
        , url = nftStorageUrl
        , headers = [ Http.header "Authorization" <| "Bearer " ++ apiKey ]
        , body = Http.fileBody file
        , expect = Http.expectJson gotFileMsg uploadRespDecoder
        , timeout = Nothing
        , tracker = Just "upload"
        }


uploadJSON : String -> (Result Http.Error String -> msg) -> E.Value -> Cmd msg
uploadJSON apiKey gotFileMsg value =
    Http.request
        { method = "POST"
        , url = nftStorageUrl
        , headers = [ Http.header "Authorization" <| "Bearer " ++ apiKey ]
        , body = Http.jsonBody value
        , expect = Http.expectJson gotFileMsg uploadRespDecoder
        , timeout = Nothing
        , tracker = Just "upload"
        }


cidToIpfsUri : String -> String
cidToIpfsUri cid =
    "ipfs://" ++ cid
