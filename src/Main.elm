port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , update
    , view
    )

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, div, h1, h3, h4, img, input, label, p, span, text)
import Html.Attributes exposing (class, classList, disabled, href, src, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import NFTMetadata
import Storage


port detectWallet : String -> Cmd msg


port nftFound : (Maybe ( String, String ) -> msg) -> Sub msg


port walletStatusNotFound : (String -> msg) -> Sub msg


port mintRequested : String -> Cmd msg


port walletError : (String -> msg) -> Sub msg


port mintRequestFailed : (String -> msg) -> Sub msg


port mintRequestSucceeded : (TokenTransfer -> msg) -> Sub msg



---- MODEL ----


type SubmitState
    = Disabled
    | Ready
    | Submitting
    | Submitted


type WalletStatus
    = Detecting
    | Detected
    | NotFound


type alias Model =
    { walletStatus : WalletStatus
    , title : String
    , description : String
    , fileCID : String
    , nftCID : String
    , dialogue : String
    , submitState : SubmitState
    , uploading : Bool
    , txnUrl : String
    , error : Maybe String
    , tokenId : String
    , contractAddress : String
    , nfts : List ( String, NFTMetadata.Model )
    , apiKey : String
    }


type alias TokenTransfer =
    { txnUrl : String
    , tokenId : String
    , contractAddress : String
    }


resetState : Model -> Model
resetState model =
    { model
        | title = ""
        , description = ""
        , fileCID = ""
        , nftCID = ""
        , dialogue = ""
        , submitState = Disabled
        , txnUrl = ""
        , error = Nothing
    }


initModel : String -> Model
initModel apiKey =
    { title = ""
    , description = ""
    , fileCID = ""
    , nftCID = ""
    , dialogue = ""
    , submitState = Disabled
    , uploading = False
    , txnUrl = ""
    , error = Nothing
    , tokenId = ""
    , contractAddress = ""
    , nfts = []
    , walletStatus = Detecting
    , apiKey = apiKey
    }


init : String -> ( Model, Cmd Msg )
init apiKey =
    ( initModel apiKey
    , detectWallet ""
    )


getNFT : String -> String -> Cmd Msg
getNFT scanUrl nftUri =
    NFTMetadata.get (String.dropLeft 7 nftUri) (NFTMetadataResponded scanUrl)



---- UPDATE ----


type Msg
    = MintRequested
    | MintRequestSucceeded TokenTransfer
    | MintRequestFailed
    | WalletError String
    | DescriptionUpdated String
    | TitleUpdated String
    | FileUploadInitiated File
    | FileUploadClicked
    | FileUploadCompleted (Result Http.Error String)
    | NFTMetadataUploadCompleted (Result Http.Error String)
    | ResetState
    | NFTMetadataResponded String (Result Http.Error NFTMetadata.Model)
    | NFTFound (Maybe ( String, String ))
    | WalletStatusNotFound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NFTFound maybeUri ->
            case maybeUri of
                Just ( uri, scanUrl ) ->
                    ( { model
                        | walletStatus = Detected
                      }
                    , getNFT scanUrl uri
                    )

                Nothing ->
                    ( { model
                        | walletStatus = Detected
                      }
                    , Cmd.none
                    )

        WalletStatusNotFound ->
            ( { model
                | walletStatus = NotFound
              }
            , Cmd.none
            )

        NFTMetadataResponded scanUrl res ->
            case res of
                Err _ ->
                    ( { model | error = Just "NFT metadata request failed. Please try again later." }, Cmd.none )

                Ok nftMetadata ->
                    ( { model | nfts = model.nfts ++ [ ( scanUrl, nftMetadata ) ] }, Cmd.none )

        MintRequested ->
            ( { model | submitState = Submitting }
            , Storage.cidToFileUrl model.fileCID
                |> NFTMetadata.build model.title model.description
                |> NFTMetadata.encodeNFTMetadata
                |> Storage.uploadJSON model.apiKey NFTMetadataUploadCompleted
            )

        MintRequestSucceeded { txnUrl, tokenId, contractAddress } ->
            ( { model
                | submitState = Submitted
                , txnUrl = txnUrl
                , tokenId = tokenId
                , contractAddress = contractAddress
              }
            , Cmd.none
            )

        MintRequestFailed ->
            ( { model | submitState = Ready }, Cmd.none )

        FileUploadInitiated file ->
            ( { model | uploading = True }, Storage.uploadFile model.apiKey FileUploadCompleted file )

        FileUploadClicked ->
            ( model, Select.file [ "image/jpeg", "image/png", "image/svg+xml", "text/plain" ] FileUploadInitiated )

        FileUploadCompleted res ->
            case res of
                Err _ ->
                    ( { model | uploading = False }, Cmd.none )

                Ok cid ->
                    ( { model | fileCID = cid, submitState = Ready, uploading = False }
                    , Cmd.none
                    )

        NFTMetadataUploadCompleted res ->
            case res of
                Err _ ->
                    ( model, Cmd.none )

                Ok cid ->
                    ( { model | nftCID = cid }, mintRequested <| Storage.cidToIpfsUri cid )

        TitleUpdated str ->
            ( { model | title = str }, Cmd.none )

        WalletError str ->
            ( { model | error = Just str, submitState = Ready }, Cmd.none )

        DescriptionUpdated str ->
            ( { model | description = str }, Cmd.none )

        ResetState ->
            ( resetState model, Cmd.none )



---- VIEW ----


notReady : Model -> Bool
notReady { title, description, fileCID, nftCID } =
    List.any (\str -> String.length str < 2) [ title, description, fileCID ]


disclaimer : Html Msg
disclaimer =
    errorDialogue "This app is in flux. Use at your own risk."


layout : Model -> Html Msg -> Html Msg
layout model content =
    div [ class "page-wrapper" ]
        [ h1 [ class "mt-3 mb-1" ] [ text "Click and Mint!" ]
        , disclaimer
        , content
        , copyright
        ]


copyright : Html Msg
copyright =
    div []
        [ div [ class "mt-3 text-right" ] [ a [ class "text-small", href "https://evanpiro.com" ] [ text "© Evan Piro 2023" ] ]
        ]


view : Model -> Html Msg
view model =
    case model.walletStatus of
        Detected ->
            layout model (viewContent model)

        Detecting ->
            layout model <| div [ class "text-white" ] [ text "detecting wallet..." ]

        NotFound ->
            layout model <|
                div [ class "text-white" ]
                    [ text "You got an error! Please ensure you have a browser wallet extension installed." ]


viewContent : Model -> Html Msg
viewContent model =
    let
        errorView =
            case model.error of
                Just error ->
                    errorDialogue error

                Nothing ->
                    span [] []
    in
    case model.submitState of
        Submitted ->
            div []
                [ div [ class "mb-1 link" ] [ div [ onClick ResetState ] [ text "<- back" ] ]
                , div [ class "my-1" ]
                    [ a
                        [ href model.txnUrl
                        , target "_blank"
                        , class "text-small"
                        ]
                        [ text "View transaction status" ]
                    ]
                , NFTMetadata.view
                    (NFTMetadata.build
                        model.title
                        model.description
                        (Storage.cidToFileUrl model.fileCID)
                    )
                ]

        _ ->
            div []
                [ div []
                    [ case model.uploading of
                        False ->
                            button [ class "btn-outline", onClick FileUploadClicked ] [ text "Upload NFT File" ]

                        True ->
                            button [ class "btn-outline", disabled True ] [ spinner ]
                    ]
                , maybePreview model
                , div []
                    [ div [] [ text "Title" ]
                    , input [ type_ "text", onInput TitleUpdated, value model.title ] []
                    ]
                , div []
                    [ div [] [ text "Description" ]
                    , input [ type_ "text", onInput DescriptionUpdated, value model.description ] []
                    ]
                , errorView
                , div []
                    [ submitButton model ]
                , NFTMetadata.listView (List.map (\( scanUrl, nft ) -> nft) model.nfts)
                ]


maybePreview : Model -> Html Msg
maybePreview model =
    case ( model.fileCID, model.nftCID ) of
        ( "", "" ) ->
            div [] []

        ( fileCID, _ ) ->
            div []
                [ img
                    [ class "width-100"
                    , src <| Storage.cidToFileUrl fileCID
                    ]
                    []
                ]


spinner : Html Msg
spinner =
    span [ class "loading" ] [ text " " ]


submitButton : Model -> Html Msg
submitButton model =
    case model.submitState of
        Disabled ->
            button
                [ class "btn"
                , classList [ ( "btn-disabled", notReady model ) ]
                , onClick MintRequested
                , disabled True
                ]
                [ text "Mint NFT" ]

        Submitting ->
            button
                [ class "btn"
                , classList [ ( "btn-disabled", notReady model ) ]
                , onClick MintRequested
                , disabled <| True
                ]
                [ span [ class "loading" ] [ text " " ] ]

        _ ->
            button
                [ class "btn"
                , classList [ ( "btn-disabled", notReady model ) ]
                , onClick MintRequested
                , disabled <| notReady model
                ]
                [ text "Mint NFT" ]


errorDialogue : String -> Html Msg
errorDialogue str =
    div [ class "text-red text-small my-1" ] [ text str ]



---- PROGRAM ----


main : Program String Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions =
            \_ ->
                Sub.batch
                    [ mintRequestFailed (\_ -> MintRequestFailed)
                    , mintRequestSucceeded MintRequestSucceeded
                    , walletError WalletError
                    , nftFound NFTFound
                    , walletStatusNotFound (\_ -> WalletStatusNotFound)
                    ]
        }
