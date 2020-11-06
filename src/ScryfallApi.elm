module ScryfallApi exposing
    ( Card
    , CardCollectionResponse
    , CardSearchResponse
    , fetchCardByName
    , fetchCardsByName
    , fetchCardsByNameMore
    , fetchCollectionByNames
    )

import Http
import Json.Decode exposing (andThen, bool, field, index, int, list, map, map2, map3, map4, maybe, oneOf, string)
import Json.Encode


type alias Card =
    { id : String
    , name : String
    , image : Maybe String
    , faces : Maybe ( CardFace, CardFace )
    }


type alias CardFace =
    { name : String
    , image : String
    }


type alias CardSearchResponse =
    { totalCards : Int
    , hasMore : Bool
    , nextPage : Maybe String
    , data : List Card
    }


type alias CardCollectionResponse =
    { data : List Card
    }


baseURL : String
baseURL =
    "https://api.scryfall.com"


cardFaceDecoder : Json.Decode.Decoder CardFace
cardFaceDecoder =
    map2 CardFace
        (field "name" string)
        (field "image_uris" (field "border_crop" string))


arrayAsTuple2 : Json.Decode.Decoder a -> Json.Decode.Decoder b -> Json.Decode.Decoder ( a, b )
arrayAsTuple2 a b =
    index 0 a
        |> andThen
            (\aVal ->
                index 1 b
                    |> andThen (\bVal -> Json.Decode.succeed ( aVal, bVal ))
            )


cardDecoder : Json.Decode.Decoder Card
cardDecoder =
    map4 Card
        (field "id" string)
        (field "name" string)
        (maybe (field "image_uris" (field "border_crop" string)))
        (maybe (field "card_faces" (arrayAsTuple2 cardFaceDecoder cardFaceDecoder)))


cardSearchResponseDecoder : Json.Decode.Decoder CardSearchResponse
cardSearchResponseDecoder =
    map4 CardSearchResponse
        (field "total_cards" int)
        (field "has_more" bool)
        (maybe (field "next_page" string))
        (field "data" (list cardDecoder))


cardCollectionResponseDecoder : Json.Decode.Decoder CardCollectionResponse
cardCollectionResponseDecoder =
    map CardCollectionResponse
        (field "data" (list cardDecoder))


fetchCardByName : String -> (Result Http.Error Card -> msg) -> Cmd msg
fetchCardByName cardName msg =
    Http.get
        { url = baseURL ++ "/cards/named?fuzzy=" ++ cardName
        , expect = Http.expectJson msg cardDecoder
        }


fetchCardsByName : String -> (Result Http.Error CardSearchResponse -> msg) -> Cmd msg
fetchCardsByName cardName msg =
    Http.get
        { url = baseURL ++ "/cards/search?unique=prints&q=!\"" ++ cardName ++ "\""
        , expect = Http.expectJson msg cardSearchResponseDecoder
        }


fetchCardsByNameMore : String -> (Result Http.Error CardSearchResponse -> msg) -> Cmd msg
fetchCardsByNameMore url msg =
    Http.get
        { url = url
        , expect = Http.expectJson msg cardSearchResponseDecoder
        }


cardNameEncoder : String -> Json.Encode.Value
cardNameEncoder cardName =
    Json.Encode.object
        [ ( "name", Json.Encode.string cardName ) ]


cardNamesEncoder : List String -> Json.Encode.Value
cardNamesEncoder cardNames =
    Json.Encode.object
        [ ( "identifiers"
          , Json.Encode.list cardNameEncoder cardNames
          )
        ]


fetchCollectionByNames : List String -> (Result Http.Error CardCollectionResponse -> msg) -> Cmd msg
fetchCollectionByNames cardNames msg =
    Http.post
        { url = baseURL ++ "/cards/collection"
        , body = Http.jsonBody <| cardNamesEncoder cardNames
        , expect = Http.expectJson msg cardCollectionResponseDecoder
        }
