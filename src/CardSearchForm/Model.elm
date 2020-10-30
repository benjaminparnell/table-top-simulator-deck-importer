module CardSearchForm.Model exposing
    ( CardSearchFormModel
    , initial
    , resetForm
    , setCardName
    , setFoundCard
    , setFoundPrintings
    , setSearchRequestStatus
    )

import RequestStatus
import ScryfallApi


type alias CardSearchFormModel =
    { cardSearchRequestStatus : Maybe RequestStatus.RequestStatus
    , cardName : String
    , foundCard : Maybe ScryfallApi.Card
    , foundPrintings : Maybe (List ScryfallApi.Card)
    }


initial : CardSearchFormModel
initial =
    CardSearchFormModel Nothing "" Nothing Nothing


resetForm : CardSearchFormModel -> CardSearchFormModel
resetForm model =
    { model | cardSearchRequestStatus = Nothing, foundCard = Nothing, foundPrintings = Nothing }


setCardName : String -> CardSearchFormModel -> CardSearchFormModel
setCardName cardName model =
    { model | cardName = cardName }


setSearchRequestStatus : RequestStatus.RequestStatus -> CardSearchFormModel -> CardSearchFormModel
setSearchRequestStatus requestStatus model =
    { model | cardSearchRequestStatus = Just requestStatus }


setFoundCard : Maybe ScryfallApi.Card -> CardSearchFormModel -> CardSearchFormModel
setFoundCard card model =
    { model | foundCard = card }


setFoundPrintings : Maybe (List ScryfallApi.Card) -> CardSearchFormModel -> CardSearchFormModel
setFoundPrintings cards model =
    { model | foundPrintings = cards }
