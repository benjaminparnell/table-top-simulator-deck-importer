module DeckImportModal.View exposing (view)

import Css
    exposing
        ( absolute
        , auto
        , backgroundColor
        , borderRadius
        , boxShadow4
        , column
        , displayFlex
        , fixed
        , flexDirection
        , height
        , hex
        , left
        , marginTop
        , padding
        , pct
        , position
        , px
        , top
        , transform
        , translate2
        , width
        , zIndex
        )
import DeckImportModal.Model
import Html.Styled exposing (Html, div, styled)
import Html.Styled.Attributes exposing (rows)
import Html.Styled.Events exposing (onClick, onInput)
import Msg exposing (Msg)
import UI


view : DeckImportModal.Model.DeckImportModalModel -> Html Msg
view model =
    styled div
        [ position fixed
        , top (px 0)
        , left (px 0)
        , width (pct 100)
        , height (pct 100)
        , backgroundColor (Css.rgba 0 0 0 0.3)
        , zIndex (Css.int 100)
        ]
        []
        [ styled div
            [ backgroundColor (hex "#FFFFFF")
            , position absolute
            , top (pct 50)
            , left (pct 50)
            , height auto
            , padding (px 10)
            , width (px 500)
            , transform (translate2 (pct -50) (pct -50))
            , borderRadius (px 5)
            , displayFlex
            , flexDirection column
            , boxShadow4 (px 1) (px 1) (px 5) (Css.rgba 0 0 0 0.5)
            , zIndex (Css.int 100)
            ]
            []
            [ Html.Styled.p []
                [ Html.Styled.text "Paste deck list" ]
            , Html.Styled.textarea [ rows 20, onInput Msg.UpdateDeckString ] []
            , UI.button [ marginTop (px 20) ] [ onClick (Msg.ImportDeck model.deckString) ] [ Html.Styled.text "Add cards to deck" ]
            , UI.button [ marginTop (px 10) ] [ onClick Msg.ToggleModal ] [ Html.Styled.text "Close" ]
            ]
        ]
