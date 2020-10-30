module Model exposing (Model, initial, setCardSearchFormModel)

import Board
import CardSearchForm.Model
import Deck
import RequestStatus
import ScryfallApi


type alias Model =
    { cardSearchFormModel : CardSearchForm.Model.CardSearchFormModel
    , deck : Deck.Deck
    , board : Board.Board
    }


initial : Model
initial =
    Model
        CardSearchForm.Model.initial
        (Deck.Deck [] [] "")
        Board.Main


setCardSearchFormModel : CardSearchForm.Model.CardSearchFormModel -> Model -> Model
setCardSearchFormModel cardSearchFormModel model =
    { model | cardSearchFormModel = cardSearchFormModel }
