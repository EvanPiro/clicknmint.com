module Route exposing (Route(..), urlToRoute)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Home
      -- network, address, token id
    | NFT String String String
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map NFT (string </> string </> string)
        ]


urlToRoute : Url -> Route
urlToRoute url =
    url
        |> parse route
        |> Maybe.withDefault NotFound



--urlToRoute : Url.Url -> Route
--urlToRoute url =
