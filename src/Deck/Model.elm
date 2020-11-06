module Deck.Model exposing
    ( CardFace
    , Deck
    , DeckCard
    , addScryfallCardToDeck
    , decreaseQuantityOfCard
    , getBoardCards
    , getName
    , hasCard
    , increaseQuantityOfCard
    , mapScryfallCardToDeckCard
    , setBoardCards
    , setCards
    , setName
    , setSideboard
    , swapCardByName
    , swapCardByNameInBoard
    )

import Board
import ScryfallApi


type alias CardFace =
    { name : String
    , image : String
    }


type alias DeckCard =
    { id : String
    , name : String
    , image : Maybe String
    , faces : Maybe ( CardFace, CardFace )
    , quantity : Int
    }


type alias Deck =
    { cards : List DeckCard
    , sideboard : List DeckCard
    , name : String
    }


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
        |> List.append [ { mappedCard | quantity = existingQuantity } ]


swapCardByNameInBoard : String -> ScryfallApi.Card -> Board.Board -> Deck -> Deck
swapCardByNameInBoard cardName card board deck =
    if board == Board.Main then
        { deck | cards = swapCardByName cardName card deck.cards }

    else
        { deck | sideboard = swapCardByName cardName card deck.sideboard }
