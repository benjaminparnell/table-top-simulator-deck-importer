module Model exposing (Model, initial, setCardSearchFormModel, setDeck, setDeckImportModalModel)

import Board
import CardSearchForm.Model
import Deck
import DeckImportModal.Model
import RequestStatus
import ScryfallApi


type alias Model =
    { cardSearchFormModel : CardSearchForm.Model.CardSearchFormModel
    , deckImportModalModel : DeckImportModal.Model.DeckImportModalModel
    , deck : Deck.Deck
    , board : Board.Board
    , isModalOpen : Bool
    }


initial : Model
initial =
    Model
        CardSearchForm.Model.initial
        DeckImportModal.Model.initial
        (Deck.Deck [] [] "")
        Board.Main
        False


setDeck : Deck.Deck -> Model -> Model
setDeck deck model =
    { model | deck = deck }


setCardSearchFormModel : CardSearchForm.Model.CardSearchFormModel -> Model -> Model
setCardSearchFormModel cardSearchFormModel model =
    { model | cardSearchFormModel = cardSearchFormModel }


setDeckImportModalModel : DeckImportModal.Model.DeckImportModalModel -> Model -> Model
setDeckImportModalModel deckImportModalModel model =
    { model | deckImportModalModel = deckImportModalModel }
