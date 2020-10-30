module Main exposing (main)

import Board
import Browser
import CardSearchForm.View
import Css exposing (backgroundColor, displayFlex, hex, none, padding, px)
import Deck
import File.Download as Download
import Html.Styled exposing (Attribute, Html, div, styled, toUnstyled)
import Model
import Msg exposing (Msg)
import RequestStatus
import ScryfallApi
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
        [ CardSearchForm.View.view model.cardSearchFormModel, Deck.view model.deck model.board ]
