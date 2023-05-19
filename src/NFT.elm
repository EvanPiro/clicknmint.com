module NFT exposing
    ( Metadata
    , NFT
    , blockDataView
    , buildMetadata
    , decoder
    , encodeMetadata
    , listView
    , nftPartsToPath
    , view
    )

import Html exposing (Html, a, div, h2, h4, img, text)
import Html.Attributes exposing (class, href, id, src)
import Http
import Json.Decode as D
import Json.Encode as Encode
import Storage


type alias NFT =
    { network : String
    , contractAddress : String
    , tokenId : String
    , title : String
    , description : String
    , image : String
    , price : Maybe String
    , owner : String
    }


decoder : D.Decoder NFT
decoder =
    D.map8 NFT
        (D.field "network" D.string)
        (D.field "contractAddress" D.string)
        (D.field "tokenId" D.string)
        (D.field "title" D.string)
        (D.field "description" D.string)
        (D.field "image" D.string)
        (D.field "price" (D.maybe D.string))
        (D.field "owner" D.string)


type alias Metadata =
    { title : String
    , description : String
    , image : String
    }



-- The third argument must be made into either an IPFS or http URL.


buildMetadata : String -> String -> String -> Metadata
buildMetadata =
    Metadata


encodeMetadata : Metadata -> Encode.Value
encodeMetadata { title, description, image } =
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


blockDataView : NFT -> Html msg
blockDataView nft =
    div [ class "text-small" ]
        [ div [] [ text "Network: ", text nft.network ]
        , div [] [ text "Address: ", text nft.contractAddress ]
        , div [] [ text "Token Id: ", text nft.tokenId ]
        , div [] [ text "Owner: ", text nft.owner ]
        ]


nftToPath : NFT -> String
nftToPath nft =
    "/" ++ nft.network ++ "/" ++ nft.contractAddress ++ "/" ++ nft.tokenId


nftPartsToPath : String -> String -> String -> String
nftPartsToPath network contractAddress tokenId =
    "/" ++ network ++ "/" ++ contractAddress ++ "/" ++ tokenId


view : Bool -> NFT -> Html msg
view isTeaser model =
    let
        fileView =
            case isTeaser of
                True ->
                    a [ href <| nftToPath model ] [ nftImg model.image ]

                False ->
                    nftImg model.image
    in
    div [ class "my-1", id model.image ]
        [ fileView
        , h4 [] [ text model.title ]
        , div [] [ text model.description ]
        ]


listView : List NFT -> Html msg
listView nfts =
    case nfts of
        [] ->
            div [] []

        _ ->
            div []
                [ div [ class "mt-3" ]
                    [ h2 [] [ text "Collection" ]
                    , div [] <| List.map (view True) nfts
                    ]
                ]
