module Msg exposing (Msg(..))

import Board
import Http
import ScryfallApi


type Msg
    = UpdateCardName String
    | SearchCardName
    | GotCard (Result Http.Error ScryfallApi.Card)
    | AddCardToDeck ScryfallApi.Card
    | AddCardToSideboard ScryfallApi.Card
    | AddOneMoreOfCardToDeck Board.Board String
    | RemoveOneOfCardFromDeck Board.Board String
    | ExportDeckToTableTopSimulator
    | UpdateDeckName String
    | UpdateBoard Board.Board
    | GetAlternativePrintings String
    | GotAlternativePrintings (Result Http.Error ScryfallApi.CardSearchResponse)
    | SwapCardArt String ScryfallApi.Card
    | ToggleModal
    | UpdateDeckString String
    | ImportDeck String
    | GotCardsFromImport (List ( String, Int )) (Result Http.Error ScryfallApi.CardCollectionResponse)
