module Deck exposing
    ( Deck
    , addScryfallCardToDeck
    , chunk
    , decreaseQuantityOfCard
    , exportDeckToTableTopSimulator
    , getName
    , hasCard
    , increaseQuantityOfCard
    , mapScryfallCardToDeckCard
    , setBoardCards
    , setCards
    , setName
    , setSideboard
    , swapCardByNameInBoard
    , view
    )

import Board
import Css
    exposing
        ( Style
        , absolute
        , backgroundColor
        , bottom
        , displayFlex
        , height
        , hex
        , int
        , justifyContent
        , left
        , margin
        , marginBottom
        , marginLeft
        , marginTop
        , maxWidth
        , minWidth
        , padding
        , padding2
        , pct
        , position
        , px
        , relative
        , right
        , spaceBetween
        , width
        , zIndex
        )
import Html.Styled exposing (Attribute, Html, button, div, img, input, p, styled, text)
import Html.Styled.Attributes exposing (attribute, name, placeholder, src, value)
import Html.Styled.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Msg exposing (Msg(..))
import ScryfallApi
import UI


type alias CardFace =
    { name : String
    , image : String
    }


type alias DeckCard =
    { id : String
    , name : String
    , image : Maybe String
    , faces : Maybe (List CardFace)
    , quantity : Int
    }


type alias Deck =
    { cards : List DeckCard
    , sideboard : List DeckCard
    , name : String
    }


type alias DeckCoords =
    { posX : Float
    , posY : Float
    , posZ : Float
    , rotX : Float
    , rotZ : Float
    , rotY : Float
    , scaleX : Float
    , scaleY : Float
    , scaleZ : Float
    }


firstDeckCoords : DeckCoords
firstDeckCoords =
    { posX = 0
    , posY = 1
    , posZ = 0
    , rotX = 0
    , rotY = 180
    , rotZ = 180
    , scaleX = 1
    , scaleY = 1
    , scaleZ = 1
    }


secondDeckCoords : DeckCoords
secondDeckCoords =
    { posX = 4.4
    , posY = 1
    , posZ = 0
    , rotX = 0
    , rotY = 180
    , rotZ = 0
    , scaleX = 1
    , scaleY = 1
    , scaleZ = 1
    }


encodeCard : DeckCard -> Encode.Value
encodeCard card =
    Encode.object
        [ ( "CardID", String.toInt card.id |> Maybe.withDefault 0 |> Encode.int )
        , ( "Name", Encode.string "Card" )
        , ( "Nickname", Encode.string card.name )
        , ( "Transform"
          , Encode.object
                [ ( "posX", Encode.int 0 )
                , ( "posY", Encode.int 0 )
                , ( "posZ", Encode.int 0 )
                , ( "rotX", Encode.int 0 )
                , ( "rotY", Encode.int 180 )
                , ( "rotZ", Encode.int 180 )
                , ( "scaleX", Encode.int 1 )
                , ( "scaleY", Encode.int 1 )
                , ( "scaleZ", Encode.int 1 )
                ]
          )
        ]


encodeImage : DeckCard -> Encode.Value
encodeImage card =
    Encode.object
        [ ( "FaceURL", Encode.string <| getCardImage card )
        , ( "BackURL", Encode.string "https://s3.amazonaws.com/frogtown.cards.hq/CardBack.jpg" )
        , ( "NumHeight", Encode.int 1 )
        , ( "NumWidth", Encode.int 1 )
        , ( "BackIsHidden", Encode.bool True )
        ]


encodeImages : List DeckCard -> Encode.Value
encodeImages cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index card -> ( String.fromInt (index + 1), encodeImage card ))
        |> Encode.object


getTTSId : Int -> String
getTTSId index =
    String.fromInt ((index + 1) * 100)


encodeContainedObjects : List DeckCard -> Encode.Value
encodeContainedObjects cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index card -> { card | id = getTTSId index })
        |> Encode.list encodeCard


encodeDeckIds : List DeckCard -> Encode.Value
encodeDeckIds cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index _ -> (index + 1) * 100)
        |> Encode.list Encode.int


expandQuantities : List DeckCard -> List DeckCard
expandQuantities cards =
    List.foldr (\card newList -> List.concat [ newList, List.repeat card.quantity card ]) [] cards


makeEncodeableDecks : Deck -> List ( List DeckCard, DeckCoords )
makeEncodeableDecks deck =
    [ ( deck.cards, firstDeckCoords ) ]
        ++ (if List.isEmpty deck.sideboard then
                []

            else
                [ ( deck.sideboard, secondDeckCoords ) ]
           )


encodeObjectStates : Deck -> Encode.Value
encodeObjectStates deck =
    Encode.object
        [ ( "ObjectStates"
          , Encode.list encodeDeck (makeEncodeableDecks deck)
          )
        ]


encodeCoords : DeckCoords -> Encode.Value
encodeCoords coords =
    Encode.object
        [ ( "posX", Encode.float coords.posX )
        , ( "posY", Encode.float coords.posY )
        , ( "posZ", Encode.float coords.posZ )
        , ( "rotX", Encode.float coords.rotX )
        , ( "rotY", Encode.float coords.rotY )
        , ( "rotZ", Encode.float coords.rotZ )
        , ( "scaleX", Encode.float coords.scaleX )
        , ( "scaleY", Encode.float coords.scaleY )
        , ( "scaleZ", Encode.float coords.scaleZ )
        ]


encodeDeck : ( List DeckCard, DeckCoords ) -> Encode.Value
encodeDeck ( cards, coords ) =
    Encode.object
        [ ( "Name", Encode.string "DeckCustom" )
        , ( "ContainedObjects", cards |> encodeContainedObjects )
        , ( "CustomDeck", cards |> encodeImages )
        , ( "DeckIDs", cards |> encodeDeckIds )
        , ( "Transform"
          , encodeCoords coords
          )
        ]


exportDeckToTableTopSimulator : Deck -> String
exportDeckToTableTopSimulator deck =
    Encode.encode 0 (encodeObjectStates deck)


mapScryfallCardToDeckCard : ScryfallApi.Card -> DeckCard
mapScryfallCardToDeckCard card =
    DeckCard card.id card.name card.image card.faces 1


addScryfallCardToDeck : ScryfallApi.Card -> List DeckCard -> List DeckCard
addScryfallCardToDeck card cards =
    mapScryfallCardToDeckCard card :: cards


getName : Deck -> String
getName deck =
    if String.isEmpty deck.name then
        "Deck"

    else
        deck.name


getBoardCards : Board.Board -> Deck -> List DeckCard
getBoardCards board deck =
    if board == Board.Main then
        deck.cards

    else
        deck.sideboard


increaseQuantityOfCard : String -> Board.Board -> Deck -> List DeckCard
increaseQuantityOfCard cardId board deck =
    List.map
        (\card ->
            if cardId == card.id then
                { card | quantity = card.quantity + 1 }

            else
                card
        )
        (getBoardCards board deck)


decreaseQuantityOfCard : String -> Board.Board -> Deck -> List DeckCard
decreaseQuantityOfCard cardId board deck =
    List.filterMap
        (\card ->
            if cardId == card.id && card.quantity /= 1 then
                Just { card | quantity = card.quantity - 1 }

            else if cardId == card.id then
                Nothing

            else
                Just card
        )
        (getBoardCards board deck)


hasCard : String -> List DeckCard -> Bool
hasCard cardId cards =
    List.any (\card -> card.id == cardId) cards


setName : String -> Deck -> Deck
setName deckName deck =
    { deck | name = deckName }


setBoardCards : Board.Board -> List DeckCard -> Deck -> Deck
setBoardCards board cards deck =
    if board == Board.Main then
        setCards cards deck

    else if board == Board.Side then
        setSideboard cards deck

    else
        deck


setCards : List DeckCard -> Deck -> Deck
setCards cards deck =
    { deck | cards = cards }


setSideboard : List DeckCard -> Deck -> Deck
setSideboard sideboard deck =
    { deck | sideboard = sideboard }


swapCardByName : String -> ScryfallApi.Card -> List DeckCard -> List DeckCard
swapCardByName cardName apiCard cards =
    let
        existingQuantity =
            List.foldr
                (\card total ->
                    if card.name == cardName then
                        card.quantity

                    else
                        total
                )
                0
                cards

        mappedCard =
            mapScryfallCardToDeckCard apiCard
    in
    cards
        |> List.filter (\card -> card.name /= cardName)
        |> List.append (List.singleton { mappedCard | quantity = existingQuantity })


swapCardByNameInBoard : String -> ScryfallApi.Card -> Board.Board -> Deck -> Deck
swapCardByNameInBoard cardName card board deck =
    if board == Board.Main then
        { deck | cards = swapCardByName cardName card deck.cards }

    else
        { deck | sideboard = swapCardByName cardName card deck.sideboard }


deckListLength : List DeckCard -> Int
deckListLength deckList =
    List.foldl (\card total -> total + card.quantity) 0 deckList


cardViewButtonStyles : List Style
cardViewButtonStyles =
    [ padding2 (px 5) (px 10), minWidth (px 0), marginLeft (px 5) ]


getCardImage : DeckCard -> String
getCardImage card =
    case card.image of
        Just image ->
            image

        Nothing ->
            card.faces
                |> Maybe.map (\cardFaces -> cardFaces |> List.head |> Maybe.map .image |> Maybe.withDefault "")
                |> Maybe.withDefault ""


cardView : Board.Board -> DeckCard -> Html Msg
cardView board card =
    styled div
        [ width (px 250), maxWidth (pct 33), position relative, padding (px 10), zIndex (int 1) ]
        []
        [ styled img [ maxWidth (pct 100), marginTop (px 0), marginBottom (px 0) ] [ src <| getCardImage card ] []
        , styled div
            [ position absolute, bottom (px 10), right (px 10), displayFlex, padding (px 10) ]
            []
            [ UI.dangerButton cardViewButtonStyles [ onClick (Msg.RemoveOneOfCardFromDeck board card.id) ] [ text "-" ]
            , UI.button cardViewButtonStyles [] [ text (String.fromInt card.quantity) ]
            , UI.successButton cardViewButtonStyles [ onClick (Msg.AddOneMoreOfCardToDeck board card.id) ] [ text "+" ]
            , UI.artButton cardViewButtonStyles [ onClick (Msg.GetAlternativePrintings card.name) ] [ text "Alt. Art" ]
            ]
        ]


cardRow : Board.Board -> List DeckCard -> Html Msg
cardRow board cards =
    styled div [ displayFlex ] [] (List.map (cardView board) cards)


chunk : Int -> List a -> List (List a)
chunk size list =
    case List.take size list of
        [] ->
            []

        head ->
            head :: chunk size (List.drop size list)


boardButton : List Css.Style -> String -> Board.Board -> Int -> Html Msg
boardButton styles buttonText board count =
    UI.textButton styles
        [ onClick (UpdateBoard board) ]
        [ text
            (buttonText
                ++ (if count > 0 then
                        " (" ++ String.fromInt count ++ ")"

                    else
                        ""
                   )
            )
        ]


view : Deck -> Board.Board -> Html Msg
view deck board =
    let
        cards =
            if board == Board.Main then
                deck.cards

            else
                deck.sideboard
    in
    styled div
        [ width (pct 100) ]
        []
        [ styled div
            [ displayFlex, justifyContent spaceBetween, backgroundColor (hex "#e3e3e3"), padding (px 15) ]
            []
            [ UI.input [] [ placeholder "Deck name", name "deckName", value deck.name, onInput UpdateDeckName ] []
            , div []
                [ boardButton [] "Main" Board.Main (deckListLength deck.cards)
                , boardButton [ marginLeft (px 10) ] "Sideboard" Board.Side (deckListLength deck.sideboard)
                ]
            , styled div
                []
                []
                [ UI.button [] [ onClick Msg.ToggleModal ] [ text "Import" ]
                , UI.button [ marginLeft (px 10) ] [ onClick Msg.ExportDeckToTableTopSimulator ] [ text "Export" ]
                ]
            ]
        , styled div [ width (pct 100) ] [] (List.map (cardRow board) (chunk 4 cards))
        ]
