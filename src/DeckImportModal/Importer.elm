module DeckImportModal.Importer exposing (getCardsFromDeckString, getDeckStringFormat, isInvalidFormat)

import Regex


type DeckStringFormat
    = NumberAndX
    | NumberOnly
    | Invalid


parseLines : String -> List String
parseLines string =
    string |> String.lines |> List.filter (\line -> not <| String.isEmpty line)


splitLines : String -> List String -> List (List String)
splitLines splitter =
    List.map (String.split splitter)


partsToCardTuple : List String -> Maybe ( String, Int )
partsToCardTuple parts =
    case parts of
        [ quantity, cardName ] ->
            Just ( cardName, String.toInt quantity |> Maybe.withDefault 1 )

        _ ->
            Nothing


getDeckStringFormat : String -> DeckStringFormat
getDeckStringFormat deckString =
    case parseLines deckString of
        [] ->
            Invalid

        lines ->
            if isStringNumberAndXFormat lines then
                NumberAndX

            else if isStringNumberOnlyFormat lines then
                NumberOnly

            else
                Invalid


numberAndXFormatRegex : Regex.Regex
numberAndXFormatRegex =
    Maybe.withDefault Regex.never <| Regex.fromString "([0-9]+) x \\w+( ?\\w+)+"


isStringNumberAndXFormat : List String -> Bool
isStringNumberAndXFormat deckStringLines =
    List.all (Regex.contains numberAndXFormatRegex) deckStringLines


numbeyOnlyFormatRegex : Regex.Regex
numbeyOnlyFormatRegex =
    Maybe.withDefault Regex.never <| Regex.fromString "([0-9]+) \\w+( ?\\w+)+"


isStringNumberOnlyFormat : List String -> Bool
isStringNumberOnlyFormat deckStringLines =
    List.all (Regex.contains numbeyOnlyFormatRegex) deckStringLines


isInvalidFormat : DeckStringFormat -> Bool
isInvalidFormat deckStringFormat =
    deckStringFormat == Invalid


getCardsFromDeckString : String -> DeckStringFormat -> List ( String, Int )
getCardsFromDeckString deckString deckStringFormat =
    if deckStringFormat == NumberAndX then
        deckString
            |> parseLines
            |> splitLines " x "
            |> List.filterMap partsToCardTuple

    else if deckStringFormat == NumberOnly then
        deckString
            |> parseLines
            |> List.map
                (\line ->
                    let
                        parts =
                            String.split " " line
                    in
                    List.concat [ [ List.head parts |> Maybe.withDefault "0" ], [ parts |> List.drop 1 |> String.join " " ] ]
                )
            |> List.filterMap partsToCardTuple

    else
        []
