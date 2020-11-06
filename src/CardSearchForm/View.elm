module CardSearchForm.View exposing (view)

import CardSearchForm.Model exposing (CardSearchFormModel)
import Css
    exposing
        ( absolute
        , border3
        , borderRadius
        , bottom
        , fixed
        , hex
        , marginBottom
        , marginRight
        , marginTop
        , maxWidth
        , none
        , overflowY
        , padding
        , padding2
        , pct
        , position
        , px
        , relative
        , right
        , scroll
        , solid
        , width
        , top
        )
import Html.Styled exposing (Attribute, Html, button, div, img, input, styled, text)
import Html.Styled.Attributes exposing (alt, disabled, placeholder, src, type_)
import Html.Styled.Events exposing (onClick, onInput)
import Model
import Msg
import RequestStatus
import ScryfallApi
import UI


getCardImage : ScryfallApi.Card -> String
getCardImage card =
    case card.image of
        Just image ->
            image

        Nothing ->
            card.faces
                |> Maybe.map (\cardFaces -> Tuple.first cardFaces |> .image)
                |> Maybe.withDefault ""


cardColumn : List ScryfallApi.Card -> Html Msg.Msg
cardColumn cards =
    styled div
        [ position fixed, top (px 75), bottom (px 0), overflowY scroll ]
        []
        (List.map
            (\card ->
                cardView [ UI.artButton [] [ onClick (Msg.SwapCardArt card.name card) ] [ text "Use art" ] ] card
            )
            cards
        )


cardView : List (Html Msg.Msg) -> ScryfallApi.Card -> Html Msg.Msg
cardView actions card =
    styled div
        [ position relative, padding (px 10), width (px 336) ]
        []
        [ styled img [ maxWidth none, width (pct 100), marginTop (px 0), marginBottom (px 0) ] [ src <| getCardImage card, alt card.name ] []
        , styled div
            [ position absolute, bottom (px 14), right (px 10), padding (px 10) ]
            []
            actions
        ]


searchCardViewButtons : ScryfallApi.Card -> List (Html Msg.Msg)
searchCardViewButtons card =
    [ UI.button
        [ marginRight (px 10) ]
        [ onClick (Msg.AddCardToDeck card) ]
        [ text "Add" ]
    , UI.button
        []
        [ onClick (Msg.AddCardToSideboard card) ]
        [ text "Add to Sideboard" ]
    ]


view : CardSearchFormModel -> Html Msg.Msg
view model =
    styled div
        [ width (pct 35), padding (px 15) ]
        []
        [ UI.input [ marginBottom (px 10) ] [ type_ "text", placeholder "Enter a card name here", onInput Msg.UpdateCardName ] []
        , UI.button [] [ onClick Msg.SearchCardName, disabled (model.cardSearchRequestStatus == Just RequestStatus.Loading) ] [ text "Search card" ]
        , case model.cardSearchRequestStatus of
            Just RequestStatus.Failure ->
                text "Looks like we couldn't find that card on Scryfall."

            _ ->
                text ""
        , case model.foundCard of
            Just card ->
                cardView (searchCardViewButtons card) card

            Nothing ->
                text ""
        , case model.foundPrintings of
            Just cards ->
                cardColumn cards

            Nothing ->
                text ""
        ]
