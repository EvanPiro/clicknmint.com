port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , update
    , view
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation exposing (load, pushUrl)
import Curation
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, div, h1, h3, h4, img, input, label, p, span, text)
import Html.Attributes exposing (class, classList, disabled, href, src, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import NFT exposing (NFT, blank)
import Route exposing (Route(..), urlToRoute)
import Storage
import Url


port detectWallet : String -> Cmd msg


type alias NFTFoundResp =
    { network : String
    , contractAddress : String
    , tokenId : String
    , tokenUri : String
    }


port nftFound : (Maybe NFTFoundResp -> msg) -> Sub msg


port walletNotFound : (String -> msg) -> Sub msg


port detectEthereum : String -> Cmd msg


port detectEthereumRes : (Bool -> msg) -> Sub msg


port walletFound : (String -> msg) -> Sub msg


port mintRequested : String -> Cmd msg


port networkError : (String -> msg) -> Sub msg


port mintRequestFailed : (String -> msg) -> Sub msg


port mintRequestSucceeded : (TokenTransfer -> msg) -> Sub msg



---- MODEL ----


type SubmitState
    = Disabled
    | Ready
    | Submitting
    | Submitted


type DetectionStatus
    = Detecting
    | Detected
    | NotFound


type alias Model =
    { walletStatus : DetectionStatus
    , ethereumStatus : DetectionStatus
    , title : String
    , description : String
    , network : String
    , contractAddress : String
    , tokenId : String
    , fileCID : String
    , nftCID : String
    , dialogue : String
    , submitState : SubmitState
    , uploading : Bool
    , txnUrl : String
    , error : Maybe String
    , nfts : List NFT
    , apiKey : String
    , navKey : Navigation.Key
    , route : Route
    , image : String
    , url : Url.Url
    }


type alias TokenTransfer =
    { txnUrl : String
    , tokenId : String
    , contractAddress : String
    , network : String
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


initModel : Url.Url -> String -> Navigation.Key -> Model
initModel url apiKey navKey =
    let
        route =
            Route.urlToRoute url

        token =
            case route of
                Route.NFT net addr tid ->
                    Maybe.withDefault blank (NFT.searchNFT Curation.list net addr tid)

                _ ->
                    blank
    in
    { title = token.title
    , description = token.description
    , fileCID = ""
    , nftCID = ""
    , network = token.network
    , contractAddress = token.contractAddress
    , tokenId = token.tokenId
    , image = token.image
    , dialogue = ""
    , submitState = Disabled
    , uploading = False
    , txnUrl = ""
    , error = Nothing
    , nfts = []
    , walletStatus = NotFound
    , apiKey = apiKey
    , ethereumStatus = Detecting
    , navKey = navKey
    , route = Route.urlToRoute url
    , url = url
    }


init : String -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init apiKey url key =
    ( initModel url apiKey key
    , detectEthereum ""
    )


getNFTMetadata : NFTFoundResp -> Cmd Msg
getNFTMetadata nftFoundRes =
    NFT.getMetadata (String.dropLeft 7 nftFoundRes.tokenUri) (NFTMetadataResponded nftFoundRes)



---- UPDATE ----


type Msg
    = UrlClicked UrlRequest
    | UrlUpdated Url.Url
    | MintRequested
    | MintRequestSucceeded TokenTransfer
    | MintRequestFailed
    | NetworkError String
    | DescriptionUpdated String
    | TitleUpdated String
    | FileUploadInitiated File
    | FileUploadClicked
    | FileUploadCompleted (Result Http.Error String)
    | NFTMetadataUploadCompleted (Result Http.Error String)
    | ResetState
    | NFTMetadataResponded NFTFoundResp (Result Http.Error NFT.Metadata)
    | NFTFound (Maybe NFTFoundResp)
    | WalletNotFound
    | WalletFound
    | DetectWallet
    | DetectEthereumRes Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlClicked urlReq ->
            ( model
            , case urlReq of
                Browser.Internal url ->
                    pushUrl model.navKey <| Url.toString url

                Browser.External url ->
                    load url
            )

        UrlUpdated url ->
            ( initModel url model.apiKey model.navKey, detectEthereum "" )

        DetectEthereumRes isDetected ->
            ( { model
                | ethereumStatus =
                    if isDetected then
                        Detected

                    else
                        NotFound
              }
            , detectWallet ""
            )

        DetectWallet ->
            ( { model | walletStatus = Detecting }, detectWallet "" )

        NFTFound maybeUri ->
            case maybeUri of
                Just nftFoundRes ->
                    ( { model
                        | walletStatus = Detected
                      }
                    , getNFTMetadata nftFoundRes
                    )

                Nothing ->
                    ( { model
                        | walletStatus = Detected
                      }
                    , Cmd.none
                    )

        WalletNotFound ->
            ( { model
                | walletStatus = NotFound
              }
            , Cmd.none
            )

        WalletFound ->
            ( { model
                | walletStatus = Detected
              }
            , Cmd.none
            )

        NFTMetadataResponded { network, contractAddress, tokenId } res ->
            case res of
                Err _ ->
                    ( { model | error = Just "NFT metadata request failed. Please try again later." }, Cmd.none )

                Ok nftMetadata ->
                    ( { model | nfts = model.nfts ++ [ NFT.build network contractAddress tokenId nftMetadata ] }, Cmd.none )

        MintRequested ->
            ( { model | submitState = Submitting }
            , Storage.cidToFileUrl model.fileCID
                |> NFT.buildMetadata model.title model.description
                |> NFT.encodeMetadata
                |> Storage.uploadJSON model.apiKey NFTMetadataUploadCompleted
            )

        MintRequestSucceeded { txnUrl, tokenId, contractAddress, network } ->
            ( { model
                | submitState = Submitted
                , txnUrl = txnUrl
                , tokenId = tokenId
                , contractAddress = contractAddress
                , network = network
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

        NetworkError str ->
            ( { model | error = Just str, submitState = Ready }, Cmd.none )

        DescriptionUpdated str ->
            ( { model | description = str }, Cmd.none )

        ResetState ->
            ( resetState model, Cmd.none )



---- VIEW ----


notReady : Model -> Bool
notReady { title, description, fileCID, nftCID } =
    List.any (\str -> String.length str < 2) [ title, description, fileCID ]


walletDialogue : Html Msg
walletDialogue =
    errorDialogue "This app is in flux. Mint at your own risk."


submittedNftView : Model -> Html Msg
submittedNftView model =
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
        , model.fileCID
            |> Storage.cidToFileUrl
            |> NFT.buildMetadata model.title model.description
            |> NFT.build model.network model.contractAddress model.tokenId
            |> (\nft -> div [] [ NFT.blockDataView nft, NFT.view nft ])
        ]


nftView : Model -> Html Msg
nftView model =
    div []
        [ model.image
            |> NFT.buildMetadata model.title model.description
            |> NFT.build model.network model.contractAddress model.tokenId
            |> (\nft -> div [] [ NFT.blockDataView nft, NFT.view nft ])
        ]


submitView : Model -> Html Msg
submitView model =
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
            submittedNftView model

        _ ->
            div []
                [ div []
                    [ case ( model.uploading, model.submitState ) of
                        ( False, Submitting ) ->
                            span [] []

                        ( True, _ ) ->
                            button [ class "btn-outline", disabled True ] [ spinner ]

                        ( False, _ ) ->
                            button [ class "btn-outline", onClick FileUploadClicked, disabled (model.submitState == Submitting) ] [ text "Upload NFT File" ]
                    ]
                , maybePreview model
                , div []
                    [ div [] [ text "Title" ]
                    , input [ type_ "text", onInput TitleUpdated, value model.title, disabled (model.submitState == Submitting) ] []
                    ]
                , div []
                    [ div [] [ text "Description" ]
                    , input [ type_ "text", onInput DescriptionUpdated, value model.description, disabled (model.submitState == Submitting) ] []
                    ]
                , errorView
                , div []
                    [ submitButton model ]
                ]


connectWalletView : Model -> Html Msg
connectWalletView model =
    case ( model.ethereumStatus, model.walletStatus ) of
        ( Detecting, _ ) ->
            div [] [ text "Detecting wallet..." ]

        ( NotFound, _ ) ->
            div []
                [ a
                    [ href "https://ethereum.org/en/wallets/find-wallet/"
                    , target "_blank"
                    ]
                    [ button [ class "btn-outline" ] [ text "Install a wallet" ] ]
                ]

        ( _, Detected ) ->
            submitView model

        ( _, Detecting ) ->
            button [ class "btn-outline", disabled True ] [ spinner ]

        ( _, NotFound ) ->
            button [ class "btn-outline", onClick DetectWallet ] [ text "Connect Wallet" ]


layout : List (Html Msg) -> Html Msg
layout content =
    div [ class "page-wrapper" ] <|
        [ a [ href "/" ] [ h1 [ class "mt-3 mb-1" ] [ text "Click and Mint!" ] ]
        ]
            ++ content
            ++ [ copyright ]


view : Model -> Html Msg
view model =
    case model.route of
        Route.NFT _ _ _ ->
            layout [ nftView model ]

        _ ->
            layout [ connectWalletView model, contentView ]


contentView : Html Msg
contentView =
    NFT.listView Curation.list


copyright : Html Msg
copyright =
    div []
        [ div [ class "mt-3 text-right" ] [ a [ class "text-small", href "https://evanpiro.com" ] [ text "© Evan Piro 2023" ] ]
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
            div []
                [ button
                    [ class "btn"
                    , classList [ ( "btn-disabled", notReady model ) ]
                    , onClick MintRequested
                    , disabled <| True
                    ]
                    [ span [ class "loading" ] [ text " " ] ]
                , span [ class "ml-1" ] [ text <| "Submitting transaction..." ]
                ]

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
    Browser.application
        { view = \model -> { title = "Click & Mint", body = [ view model ] }
        , init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlUpdated
        , update = update
        , subscriptions =
            \_ ->
                Sub.batch
                    [ mintRequestFailed (\_ -> MintRequestFailed)
                    , mintRequestSucceeded MintRequestSucceeded
                    , networkError NetworkError
                    , nftFound NFTFound
                    , walletNotFound (\_ -> WalletNotFound)
                    , walletFound (\_ -> WalletFound)
                    , detectEthereumRes DetectEthereumRes
                    ]
        }
