module DeckImportModal.Importer exposing (getCardsFromDeckString, getDeckStringFormat, isInvalidFormat)

import Regex


type DeckStringFormat
    = NumberAndX
    | NumberOnly
    | Invalid


getDeckStringFormat : String -> DeckStringFormat
getDeckStringFormat deckString =
    let
        deckStringLines =
            deckString
                |> String.lines
                |> List.filter (\line -> not <| String.isEmpty line)
    in
    case deckStringLines of
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
            |> String.lines
            |> List.filter (\line -> not <| String.isEmpty line)
            |> List.map (String.split " x ")
            |> List.filterMap
                (\parts ->
                    case parts of
                        [ quantity, cardName ] ->
                            Just ( cardName, String.toInt quantity |> Maybe.withDefault 1 )

                        _ ->
                            Nothing
                )

    else if deckStringFormat == NumberOnly then
        deckString
            |> String.lines
            |> List.filter (\line -> not <| String.isEmpty line)
            |> List.map
                (\line ->
                    let
                        parts =
                            String.split " " line
                    in
                    List.concat [ [ List.head parts |> Maybe.withDefault "0" ], [ parts |> List.drop 1 |> String.join " " ] ]
                )
            |> List.filterMap
                (\parts ->
                    case parts of
                        [ quantity, cardName ] ->
                            Just ( cardName, String.toInt quantity |> Maybe.withDefault 1 )

                        _ ->
                            Nothing
                )

    else
        []
