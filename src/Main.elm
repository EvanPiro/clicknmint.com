port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , update
    , view
    )

import API
import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation exposing (load, pushUrl)
import Curation
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, div, h1, h3, img, input, span, text)
import Html.Attributes exposing (class, classList, disabled, href, id, src, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import NFT exposing (NFT)
import Route exposing (Route(..), urlToRoute)
import Storage
import Url


port detectWallet : String -> Cmd msg


port walletNotFound : (String -> msg) -> Sub msg


port detectEthereum : String -> Cmd msg


port buyListing : NFT -> Cmd msg


port setListing : NFT -> Cmd msg


port buyListingRes : (Maybe String -> msg) -> Sub msg


port setListingRes : (Maybe String -> msg) -> Sub msg


port detectEthereumRes : (Bool -> msg) -> Sub msg


port walletFound : (String -> msg) -> Sub msg


port mintRequested : String -> Cmd msg


port networkError : (String -> msg) -> Sub msg


port mintRequestFailed : (String -> msg) -> Sub msg


port mintRequestSucceeded : (MintMetadata -> msg) -> Sub msg



---- MODEL ----


type SubmitState
    = Disabled
    | Ready
    | Submitting
    | Submitted


type LoadState
    = NotLoading
    | Loading
    | LoadingError String
    | Loaded


type DetectionStatus
    = Detecting
    | Detected
    | NotFound


type ContentStatus a
    = NotRequested
    | Requesting
    | ContentFound a
    | ContentNotFound


contentStatusToMaybe : ContentStatus a -> Maybe a
contentStatusToMaybe c =
    case c of
        ContentFound t ->
            Just t

        _ ->
            Nothing


type alias Model =
    { walletStatus : DetectionStatus
    , ethereumStatus : DetectionStatus
    , title : String
    , description : String
    , fileCID : String
    , nftCID : String
    , dialogue : String
    , submitting : SubmitState
    , uploading : LoadState
    , error : Maybe String
    , apiKey : String
    , navKey : Navigation.Key
    , route : Route
    , image : String
    , nft : ContentStatus NFT
    , userAddress : Maybe String
    , price : String
    }


type alias MintMetadata =
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
        , submitting = Disabled
        , error = Nothing
    }


init : String -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init apiKey url navKey =
    let
        ( requestStatus, cmd ) =
            case urlToRoute url of
                Route.NFT n a id ->
                    ( Requesting, API.getNFT n a id GotNFTRes )

                _ ->
                    ( NotRequested, Cmd.none )
    in
    ( { title = ""
      , description = ""
      , fileCID = ""
      , nftCID = ""
      , image = ""
      , dialogue = ""
      , submitting = Disabled
      , uploading = NotLoading
      , error = Nothing
      , walletStatus = NotFound
      , apiKey = apiKey
      , ethereumStatus = Detecting
      , navKey = navKey
      , route = Route.urlToRoute url
      , nft = requestStatus
      , userAddress = Nothing
      , price = ""
      }
    , Cmd.batch [ cmd, detectEthereum "" ]
    )



---- UPDATE ----


type Msg
    = UrlClicked UrlRequest
    | UrlUpdated Url.Url
    | MintRequested
    | MintRequestSucceeded MintMetadata
    | MintRequestFailed
    | NetworkError String
    | DescriptionUpdated String
    | TitleUpdated String
    | FileUploadInitiated File
    | FileUploadClicked
    | FileUploadCompleted (Result Http.Error String)
    | NFTMetadataUploadCompleted (Result Http.Error String)
    | ResetState
    | WalletNotFound
    | WalletFound String
    | DetectWallet
    | DetectEthereumRes Bool
    | GotNFTRes (Result Http.Error NFT)
    | BuyListing NFT
    | BuyListingRes (Maybe String)
    | SetListing NFT String
    | SetListingRes (Maybe String)
    | RemoveListing NFT
    | PriceUpdated String


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
            let
                route =
                    Route.urlToRoute url
            in
            case route of
                Route.NFT net addr tid ->
                    ( { model | route = route, nft = Requesting }, API.getNFT net addr tid GotNFTRes )

                _ ->
                    ( { model | route = route }, Cmd.none )

        GotNFTRes res ->
            case res of
                Ok nft ->
                    ( { model | nft = ContentFound nft }, Cmd.none )

                Err _ ->
                    ( { model | nft = ContentNotFound }, Cmd.none )

        DetectEthereumRes isDetected ->
            ( { model
                | ethereumStatus =
                    if isDetected then
                        Detected

                    else
                        NotFound
              }
            , Cmd.none
            )

        DetectWallet ->
            ( { model | walletStatus = Detecting }, detectWallet "" )

        WalletNotFound ->
            ( { model
                | walletStatus = NotFound
              }
            , Cmd.none
            )

        WalletFound address ->
            ( { model
                | walletStatus = Detected
                , userAddress = Just address
              }
            , Cmd.none
            )

        MintRequested ->
            ( { model | submitting = Submitting }
            , Storage.cidToFileUrl model.fileCID
                |> NFT.buildMetadata model.title model.description
                |> NFT.encodeMetadata
                |> Storage.uploadJSON model.apiKey NFTMetadataUploadCompleted
            )

        MintRequestSucceeded { network, contractAddress, tokenId } ->
            ( { model
                | submitting = Submitted
                , route = Route.NFT network contractAddress tokenId
                , nft = Requesting
              }
            , Cmd.batch
                [ pushUrl model.navKey <|
                    NFT.nftPartsToPath network contractAddress tokenId
                , API.getNFT network contractAddress tokenId GotNFTRes
                ]
            )

        MintRequestFailed ->
            ( { model | submitting = Ready }, Cmd.none )

        FileUploadInitiated file ->
            ( { model | uploading = Loading }, Storage.uploadFile model.apiKey FileUploadCompleted file )

        FileUploadClicked ->
            ( model, Select.file [ "image/jpeg", "image/png", "image/svg+xml", "text/plain" ] FileUploadInitiated )

        FileUploadCompleted res ->
            case res of
                Err _ ->
                    ( { model | uploading = LoadingError "upload error" }, Cmd.none )

                Ok cid ->
                    ( { model | fileCID = cid, submitting = Ready, uploading = Loaded }
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
            ( { model | error = Just str, submitting = Ready }, Cmd.none )

        DescriptionUpdated str ->
            ( { model | description = str }, Cmd.none )

        ResetState ->
            ( resetState model, Cmd.none )

        BuyListing nft ->
            ( { model | submitting = Submitting }, buyListing nft )

        PriceUpdated price ->
            ( { model | price = price }, Cmd.none )

        SetListing nft price ->
            ( { model | submitting = Submitting }, setListing { nft | price = Just price } )

        SetListingRes _ ->
            let
                cmd =
                    model.nft
                        |> contentStatusToMaybe
                        |> Maybe.map
                            (\{ network, contractAddress, tokenId } ->
                                API.getNFT network contractAddress tokenId GotNFTRes
                            )
                        |> Maybe.withDefault Cmd.none
            in
            ( { model | submitting = Submitted, nft = Requesting }, cmd )

        BuyListingRes _ ->
            let
                cmd =
                    model.nft
                        |> contentStatusToMaybe
                        |> Maybe.map
                            (\{ network, contractAddress, tokenId } ->
                                API.getNFT network contractAddress tokenId GotNFTRes
                            )
                        |> Maybe.withDefault Cmd.none
            in
            ( { model | submitting = Submitted }, cmd )

        RemoveListing nft ->
            ( model, Cmd.none )



---- VIEW ----


notReady : Model -> Bool
notReady { title, description, fileCID, nftCID } =
    List.any (\str -> String.length str < 2) [ title, description, fileCID ]


nftView : Model -> NFT -> Html Msg
nftView model nft =
    div [ id (nft.contractAddress ++ nft.tokenId) ] [ listingView model nft, NFT.view nft, NFT.blockDataView nft ]


listingView : Model -> NFT -> Html Msg
listingView model nft =
    case ( model.userAddress, nft.price ) of
        ( Just addr, Nothing ) ->
            case addr == nft.owner of
                True ->
                    div []
                        [ div [] [ text "This one's yours!" ]
                        , div [] [ text "Price (ETH)" ]
                        , input
                            [ type_ "text"
                            , onInput PriceUpdated
                            , value model.price
                            , disabled (model.submitting == Submitting)
                            ]
                            []
                        , div []
                            [ button
                                [ class "btn-outline"
                                , onClick (SetListing nft model.price)
                                , disabled (model.submitting == Submitting)
                                ]
                                [ if model.submitting == Submitting then
                                    spinner

                                  else
                                    text "List for Sale"
                                ]
                            ]
                        ]

                False ->
                    div [] [ text "Not for Sale" ]

        ( Just addr, Just price ) ->
            case addr == nft.owner of
                True ->
                    div []
                        [ div [] [ text "This one's yours!" ]
                        , h3 [ class "text-red" ] [ text <| "Price: " ++ price ++ " ETH" ]

                        --, button [ class "btn-outline", onClick (RemoveListing nft) ] [ text "Remove Price Listing" ]
                        ]

                False ->
                    div []
                        [ button
                            [ class "btn-outline"
                            , onClick (BuyListing nft)
                            , disabled (model.submitting == Submitting)
                            ]
                            [ if model.submitting == Submitting then
                                spinner

                              else
                                text <| "Buy for " ++ price ++ " ETH"
                            ]
                        ]

        ( Nothing, Just price ) ->
            div []
                [ h3 [ class "text-red" ] [ text <| "Price: " ++ price ++ " ETH" ]
                , button [ class "btn-outline", onClick DetectWallet ] [ text "Connect Wallet" ]
                ]

        ( Nothing, Nothing ) ->
            div [] []


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
    case model.submitting of
        Submitted ->
            span [] []

        _ ->
            div []
                [ div []
                    [ case ( model.uploading, model.submitting ) of
                        ( NotLoading, Submitting ) ->
                            span [] []

                        ( Loading, _ ) ->
                            button [ class "btn-outline", disabled True ] [ spinner ]

                        ( _, _ ) ->
                            button [ class "btn-outline", onClick FileUploadClicked, disabled (model.submitting == Submitting) ] [ text "Upload NFT File" ]
                    ]
                , maybePreview model
                , div []
                    [ div [] [ text "Title" ]
                    , input [ type_ "text", onInput TitleUpdated, value model.title, disabled (model.submitting == Submitting) ] []
                    ]
                , div []
                    [ div [] [ text "Description" ]
                    , input [ type_ "text", onInput DescriptionUpdated, value model.description, disabled (model.submitting == Submitting) ] []
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
    let
        content =
            case model.route of
                Route.NFT _ _ _ ->
                    case model.nft of
                        NotRequested ->
                            span [] []

                        Requesting ->
                            div [] [ text "Loading NFT data..." ]

                        ContentFound nft ->
                            nftView model nft

                        ContentNotFound ->
                            div [] [ text "Not found" ]

                _ ->
                    div [] [ connectWalletView model, contentView ]
    in
    layout [ content ]


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
    case model.submitting of
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
                    , walletNotFound (\_ -> WalletNotFound)
                    , walletFound WalletFound
                    , detectEthereumRes DetectEthereumRes
                    , buyListingRes BuyListingRes
                    , setListingRes SetListingRes
                    ]
        }
