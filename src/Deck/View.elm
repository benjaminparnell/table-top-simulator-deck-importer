module Deck.View exposing
    ( getCardImage
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
import Deck.Model exposing (Deck, DeckCard)
import Html.Styled exposing (Attribute, Html, button, div, img, input, p, styled, text)
import Html.Styled.Attributes exposing (attribute, name, placeholder, src, value)
import Html.Styled.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Msg exposing (Msg(..))
import ScryfallApi
import Svg.Styled exposing (image)
import UI
import Util


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
                |> Maybe.map (\cardFaces -> Tuple.first cardFaces |> .image)
                |> Maybe.withDefault ""


cardView : Board.Board -> DeckCard -> Html Msg
cardView board card =
    styled div
        [ width (px 250), maxWidth (pct 33), position relative, padding (px 10), zIndex (int 1), height (px 350) ]
        []
        [ styled img [ maxWidth (pct 100), marginTop (px 0), marginBottom (px 0) ] [ src <| getCardImage card ] []
        , styled div
            [ position absolute, bottom (px 6), right (px 10), displayFlex, padding (px 10) ]
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
            [ displayFlex, justifyContent spaceBetween, backgroundColor (hex UI.colors.grey), padding (px 15) ]
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
        , styled div [ width (pct 100) ] [] (List.map (cardRow board) (Util.chunk 4 cards))
        ]
