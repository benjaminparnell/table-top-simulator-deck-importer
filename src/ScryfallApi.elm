module ScryfallApi exposing (Card, CardSearchResponse, fetchCardByName, fetchCardsByName)

import Http
import Json.Decode exposing (bool, field, int, list, map3, map4, maybe, string)


type alias Card =
    { id : String
    , name : String
    , image : String
    }


type alias CardSearchResponse =
    { totalCards : Int
    , hasMore : Bool
    , nextPage : Maybe String
    , data : List Card
    }


baseURL : String
baseURL =
    "https://api.scryfall.com"


cardDecoder : Json.Decode.Decoder Card
cardDecoder =
    map3 Card
        (field "id" string)
        (field "name" string)
        (field "image_uris" (field "border_crop" string))


cardSearchResponseDecoder : Json.Decode.Decoder CardSearchResponse
cardSearchResponseDecoder =
    map4 CardSearchResponse
        (field "total_cards" int)
        (field "has_more" bool)
        (maybe (field "next_page" string))
        (field "data" (list cardDecoder))


fetchCardByName : String -> (Result Http.Error Card -> msg) -> Cmd msg
fetchCardByName cardName msg =
    Http.get
        { url = baseURL ++ "/cards/named?fuzzy=" ++ cardName, expect = Http.expectJson msg cardDecoder }


fetchCardsByName : String -> (Result Http.Error CardSearchResponse -> msg) -> Cmd msg
fetchCardsByName cardName msg =
    Http.get
        { url = baseURL ++ "/cards/search?unique=prints&q=" ++ cardName, expect = Http.expectJson msg cardSearchResponseDecoder }
