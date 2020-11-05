module DeckImportModal.Model exposing (DeckImportModalModel, initial, setDeckString)


type alias DeckImportModalModel =
    { deckString : String
    }


initial : DeckImportModalModel
initial =
    DeckImportModalModel ""


setDeckString : String -> DeckImportModalModel -> DeckImportModalModel
setDeckString deckString model =
    { model | deckString = deckString }
