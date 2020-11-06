module Main exposing (main)

import Browser
import CardSearchForm.View
import Css exposing (displayFlex)
import Deck.View
import DeckImportModal.View
import Html.Styled exposing (Attribute, Html, div, styled, toUnstyled)
import Model
import Msg exposing (Msg)
import Update


init : () -> ( Model.Model, Cmd Msg )
init _ =
    ( Model.initial, Cmd.none )


subscriptions : Model.Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model.Model Msg
main =
    Browser.element { init = init, update = Update.update, view = view >> toUnstyled, subscriptions = subscriptions }


view : Model.Model -> Html Msg
view model =
    styled div
        [ displayFlex ]
        []
        [ if model.isModalOpen then
            DeckImportModal.View.view model.deckImportModalModel

          else
            Html.Styled.text ""
        , CardSearchForm.View.view model.cardSearchFormModel
        , Deck.View.view model.deck model.board
        ]
