module CardSearchForm.Model exposing
    ( CardSearchFormModel
    , initial
    , resetForm
    , setCardName
    , setFoundCard
    , setFoundPrintings
    , setSearchRequestStatus
    , setSetCode
    )

import RequestStatus
import ScryfallApi


type alias CardSearchFormModel =
    { cardSearchRequestStatus : RequestStatus.RequestStatus
    , cardName : String
    , setCode : String
    , foundCard : Maybe ScryfallApi.Card
    , foundPrintings : Maybe (List ScryfallApi.Card)
    }


initial : CardSearchFormModel
initial =
    CardSearchFormModel RequestStatus.Initial "" "" Nothing Nothing


resetForm : CardSearchFormModel -> CardSearchFormModel
resetForm model =
    { model | cardSearchRequestStatus = RequestStatus.Initial, foundCard = Nothing, foundPrintings = Nothing }


setCardName : String -> CardSearchFormModel -> CardSearchFormModel
setCardName cardName model =
    { model | cardName = cardName }


setSearchRequestStatus : RequestStatus.RequestStatus -> CardSearchFormModel -> CardSearchFormModel
setSearchRequestStatus requestStatus model =
    { model | cardSearchRequestStatus = requestStatus }


setFoundCard : Maybe ScryfallApi.Card -> CardSearchFormModel -> CardSearchFormModel
setFoundCard card model =
    { model | foundCard = card }


setFoundPrintings : Maybe (List ScryfallApi.Card) -> CardSearchFormModel -> CardSearchFormModel
setFoundPrintings cards model =
    { model | foundPrintings = cards }


setSetCode : String -> CardSearchFormModel -> CardSearchFormModel
setSetCode setCode model =
    { model | setCode = setCode }
