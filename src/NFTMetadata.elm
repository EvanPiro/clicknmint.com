module NFTMetadata exposing (Model, build, encodeNFTMetadata, get, listView, view)

import Html exposing (Html, div, h4, img, text)
import Html.Attributes exposing (class, id, src)
import Http
import Json.Decode as D
import Json.Encode as Encode
import Storage


type alias Model =
    { title : String
    , description : String
    , image : String
    }


build : String -> String -> String -> Model
build =
    Model


encodeNFTMetadata : Model -> Encode.Value
encodeNFTMetadata { title, description, image } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "description", Encode.string description )
        , ( "image", Encode.string image )
        ]


nftImg : String -> Html msg
nftImg image =
    div []
        [ img
            [ class "width-100"
            , src <| image
            ]
            []
        ]


{-| Decoder to decode a JSON body into NFTMetadata with the following structure:

{
title: "Apple King",
description: "MSPaint",
image: "<https://cloudflare-ipfs.com/ipfs/bafkreif2fgiihlkvnbcgjdzejqrfxvbgbwt2ktwzyzhy3fnjgewscgfvwi">
}

-}
decoder : D.Decoder Model
decoder =
    D.map3 Model
        (D.field "title" D.string)
        (D.field "description" D.string)
        (D.field "image" D.string)


get : String -> (Result Http.Error Model -> msg) -> Cmd msg
get cid gotNFTMetadataMsg =
    Http.get
        { url = Storage.cidToFileUrl cid
        , expect = Http.expectJson gotNFTMetadataMsg decoder
        }


view : Model -> Html msg
view model =
    div [ class "my-1", id model.image ]
        [ nftImg model.image
        , h4 [] [ text model.title ]
        , div [] [ text model.description ]
        ]


listView : List Model -> Html msg
listView nfts =
    case nfts of
        [] ->
            div [] []

        _ ->
            div []
                [ div [ class "mt-3" ]
                    [ h4 [] [ text "Collection" ]
                    , div [ id "scrollend" ] <| List.map view nfts
                    ]
                ]
