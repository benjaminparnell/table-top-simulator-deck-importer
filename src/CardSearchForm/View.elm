module CardSearchForm.View exposing (view)

import CardSearchForm.Model exposing (CardSearchFormModel)
import Css
    exposing
        ( absolute
        , border3
        , borderRadius
        , bottom
        , displayFlex
        , fixed
        , height
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
        , top
        , width
        )
import Html.Styled exposing (Attribute, Html, button, div, img, input, styled, text)
import Html.Styled.Attributes exposing (alt, disabled, placeholder, src, type_, value)
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


cardColumn : List ScryfallApi.Card -> String -> Html Msg.Msg
cardColumn cards setCode =
    styled div
        [ position fixed, top (px 100), bottom (px 0), overflowY scroll ]
        []
        (List.filterMap
            (\card ->
                if not (String.isEmpty setCode) then
                    if card.set == String.toLower setCode then
                        Just (cardView [ UI.artButton [] [ onClick (Msg.SwapCardArt card.name card) ] [ text "Use art" ] ] card)

                    else
                        Nothing

                else
                    Just (cardView [ UI.artButton [] [ onClick (Msg.SwapCardArt card.name card) ] [ text "Use art" ] ] card)
            )
            cards
        )


cardView : List (Html Msg.Msg) -> ScryfallApi.Card -> Html Msg.Msg
cardView actions card =
    styled div
        [ position relative, padding (px 10), width (px 336), height (px 480) ]
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
        ([ styled div
            [ displayFlex, marginBottom (px 10) ]
            []
            [ UI.input [ marginRight (px 10) ] [ type_ "text", placeholder "Enter a card name here", onInput Msg.UpdateCardName ] []
            , UI.button [] [ onClick Msg.SearchCardName, disabled (model.cardSearchRequestStatus == RequestStatus.Loading) ] [ text "Search card" ]
            ]
         , case model.cardSearchRequestStatus of
            RequestStatus.Failure ->
                text "Looks like we couldn't find that card on Scryfall."

            _ ->
                text ""
         , case model.foundCard of
            Just card ->
                cardView (searchCardViewButtons card) card

            Nothing ->
                text ""
         ]
            ++ (case model.foundPrintings of
                    Just cards ->
                        [ UI.input
                            [ displayFlex, width (px 315) ]
                            [ type_ "text", placeholder "Filter by set code (ELD, CMR etc)", value model.setCode, onInput Msg.UpdateSetCode ]
                            []
                        , cardColumn cards model.setCode
                        ]

                    Nothing ->
                        [ text "" ]
               )
        )
