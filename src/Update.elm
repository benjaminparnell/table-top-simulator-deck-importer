module Update exposing (update)

import Board
import CardSearchForm.Model as CardSearchFormModel
import Deck.Export as DeckExport
import Deck.Model as Deck
import DeckImportModal.Importer as DeckImporter
import DeckImportModal.Model
import File.Download as Download
import Model
import Msg
import RequestStatus
import ScryfallApi
import Util


update : Msg.Msg -> Model.Model -> ( Model.Model, Cmd Msg.Msg )
update msg model =
    case msg of
        Msg.UpdateCardName cardName ->
            ( Model.setCardSearchFormModel (model.cardSearchFormModel |> CardSearchFormModel.setCardName cardName) model, Cmd.none )

        Msg.SearchCardName ->
            ( Model.setCardSearchFormModel
                (model.cardSearchFormModel
                    |> CardSearchFormModel.resetForm
                    |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Loading
                )
                model
            , ScryfallApi.fetchCardByName model.cardSearchFormModel.cardName Msg.GotCard
            )

        Msg.GotCard result ->
            case result of
                Ok card ->
                    ( Model.setCardSearchFormModel
                        (model.cardSearchFormModel
                            |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Success
                            |> CardSearchFormModel.setFoundCard (Just card)
                        )
                        model
                    , Cmd.none
                    )

                Err _ ->
                    ( Model.setCardSearchFormModel
                        (model.cardSearchFormModel
                            |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Failure
                            |> CardSearchFormModel.setFoundCard Nothing
                        )
                        model
                    , Cmd.none
                    )

        Msg.AddCardToDeck card ->
            ( { model
                | deck =
                    if Deck.hasCard card.id model.deck.cards then
                        Deck.setCards (Deck.increaseQuantityOfCard card.id Board.Main model.deck) model.deck

                    else
                        Deck.setCards (Deck.addScryfallCardToDeck card model.deck.cards) model.deck
              }
            , Cmd.none
            )

        Msg.AddCardToSideboard card ->
            ( { model
                | deck =
                    if Deck.hasCard card.id model.deck.sideboard then
                        Deck.setSideboard (Deck.increaseQuantityOfCard card.id Board.Side model.deck) model.deck

                    else
                        Deck.setSideboard (Deck.addScryfallCardToDeck card model.deck.sideboard) model.deck
              }
            , Cmd.none
            )

        Msg.AddOneMoreOfCardToDeck board cardId ->
            ( { model | deck = Deck.setBoardCards board (Deck.increaseQuantityOfCard cardId board model.deck) model.deck }, Cmd.none )

        Msg.RemoveOneOfCardFromDeck board cardId ->
            ( { model | deck = Deck.setBoardCards board (Deck.decreaseQuantityOfCard cardId board model.deck) model.deck }, Cmd.none )

        Msg.ExportDeckToTableTopSimulator ->
            ( model, Download.string (Deck.getName model.deck ++ ".json") "application/json" (DeckExport.exportDeckToTableTopSimulator model.deck) )

        Msg.UpdateDeckName deckName ->
            ( { model | deck = Deck.setName deckName model.deck }, Cmd.none )

        Msg.UpdateBoard board ->
            ( { model | board = board }, Cmd.none )

        Msg.GetAlternativePrintings name ->
            ( Model.setCardSearchFormModel
                (model.cardSearchFormModel
                    |> CardSearchFormModel.resetForm
                    |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Loading
                )
                model
            , ScryfallApi.fetchCardsByName name Msg.GotAlternativePrintings
            )

        Msg.GotAlternativePrintings result ->
            case result of
                Ok response ->
                    ( Model.setCardSearchFormModel
                        (model.cardSearchFormModel
                            |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Success
                            |> CardSearchFormModel.setFoundPrintings
                                (model.cardSearchFormModel.foundPrintings
                                    |> Maybe.map (\prints -> prints ++ response.data)
                                    |> Maybe.withDefault response.data
                                    |> Just
                                )
                        )
                        model
                    , case response.nextPage of
                        Just url ->
                            ScryfallApi.fetchCardsByNameMore url Msg.GotAlternativePrintings

                        Nothing ->
                            Cmd.none
                    )

                Err _ ->
                    ( Model.setCardSearchFormModel
                        (model.cardSearchFormModel
                            |> CardSearchFormModel.setSearchRequestStatus RequestStatus.Failure
                        )
                        model
                    , Cmd.none
                    )

        Msg.SwapCardArt cardName cardWithNewArt ->
            ( { model | deck = Deck.swapCardByNameInBoard cardName cardWithNewArt Board.Main model.deck }, Cmd.none )

        Msg.ToggleModal ->
            ( { model | isModalOpen = not model.isModalOpen }, Cmd.none )

        Msg.ImportDeck deckString ->
            let
                deckStringFormat =
                    DeckImporter.getDeckStringFormat deckString

                cards =
                    DeckImporter.getCardsFromDeckString deckString deckStringFormat

                cardNames =
                    List.map (\t -> Tuple.first t) cards
            in
            if DeckImporter.isInvalidFormat deckStringFormat then
                ( model, Cmd.none )

            else if List.isEmpty cards then
                ( model, Cmd.none )

            else
                ( model
                , Util.chunk 75 cardNames
                    |> List.map (\cardChunk -> ScryfallApi.fetchCollectionByNames cardChunk (Msg.GotCardsFromImport cards))
                    |> Cmd.batch
                )

        Msg.GotCardsFromImport cardsWithQuantities result ->
            case result of
                Ok response ->
                    ( Model.setDeck
                        (Deck.setBoardCards
                            Board.Main
                            ((response.data
                                |> List.map
                                    (\card ->
                                        let
                                            mappedCard =
                                                Deck.mapScryfallCardToDeckCard card

                                            cardQuantity =
                                                List.foldl
                                                    (\cardWithQuantity quantity ->
                                                        if Tuple.first cardWithQuantity == mappedCard.name then
                                                            Tuple.second cardWithQuantity

                                                        else
                                                            quantity
                                                    )
                                                    1
                                                    cardsWithQuantities
                                        in
                                        { mappedCard | quantity = cardQuantity }
                                    )
                             )
                                ++ model.deck.cards
                            )
                            model.deck
                        )
                        model
                    , Cmd.none
                    )

                Err err ->
                    ( model, Cmd.none )

        Msg.UpdateDeckString deckString ->
            ( Model.setDeckImportModalModel
                (DeckImportModal.Model.setDeckString deckString model.deckImportModalModel)
                model
            , Cmd.none
            )

        Msg.UpdateSetCode setCode ->
            ( Model.setCardSearchFormModel (model.cardSearchFormModel |> CardSearchFormModel.setSetCode setCode) model, Cmd.none )
