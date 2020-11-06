module Deck.Export exposing (..)

import Deck.View as DeckView
import Deck.Model as Deck
import Json.Encode as Encode


type alias DeckCoords =
    { posX : Float
    , posY : Float
    , posZ : Float
    , rotX : Float
    , rotZ : Float
    , rotY : Float
    , scaleX : Float
    , scaleY : Float
    , scaleZ : Float
    }


firstDeckCoords : DeckCoords
firstDeckCoords =
    { posX = 0
    , posY = 1
    , posZ = 0
    , rotX = 0
    , rotY = 180
    , rotZ = 180
    , scaleX = 1
    , scaleY = 1
    , scaleZ = 1
    }


secondDeckCoords : DeckCoords
secondDeckCoords =
    { posX = 4.4
    , posY = 1
    , posZ = 0
    , rotX = 0
    , rotY = 180
    , rotZ = 0
    , scaleX = 1
    , scaleY = 1
    , scaleZ = 1
    }


thirdDeckCoords : DeckCoords
thirdDeckCoords =
    { posX = 6.6000000000000005
    , posY = 1
    , posZ = 0
    , rotX = 0
    , rotY = 180
    , rotZ = 0
    , scaleX = 1
    , scaleY = 1
    , scaleZ = 1
    }


encodeCardFields : Deck.DeckCard -> List ( String, Encode.Value )
encodeCardFields card =
    [ ( "CardID", String.toInt card.id |> Maybe.withDefault 0 |> Encode.int )
    , ( "Name", Encode.string "Card" )
    , ( "Nickname", Encode.string card.name )
    , ( "Transform"
      , Encode.object
            [ ( "posX", Encode.int 0 )
            , ( "posY", Encode.int 0 )
            , ( "posZ", Encode.int 0 )
            , ( "rotX", Encode.int 0 )
            , ( "rotY", Encode.int 180 )
            , ( "rotZ", Encode.int 180 )
            , ( "scaleX", Encode.int 1 )
            , ( "scaleY", Encode.int 1 )
            , ( "scaleZ", Encode.int 1 )
            ]
      )
    ]


encodeCard : Deck.DeckCard -> Encode.Value
encodeCard card =
    Encode.object <| encodeCardFields card


getBackImageUrl : Deck.DeckCard -> Bool -> String
getBackImageUrl card doubleFaced =
    if doubleFaced then
        card.faces
            |> Maybe.map (\cardFaces -> Tuple.second cardFaces |> .image)
            |> Maybe.withDefault "https://s3.amazonaws.com/frogtown.cards.hq/CardBack.jpg"

    else
        "https://s3.amazonaws.com/frogtown.cards.hq/CardBack.jpg"


encodeImage : Bool -> Deck.DeckCard -> Encode.Value
encodeImage doubleFaced card =
    Encode.object
        [ ( "FaceURL", Encode.string <| DeckView.getCardImage card )
        , ( "BackURL", Encode.string <| getBackImageUrl card doubleFaced )
        , ( "NumHeight", Encode.int 1 )
        , ( "NumWidth", Encode.int 1 )
        , ( "BackIsHidden", Encode.bool True )
        ]


encodeImages : Bool -> List Deck.DeckCard -> Encode.Value
encodeImages doubleFaced cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index card -> ( String.fromInt (index + 1), encodeImage doubleFaced card ))
        |> Encode.object


getTTSId : Int -> String
getTTSId index =
    String.fromInt ((index + 1) * 100)


encodeContainedObjects : List Deck.DeckCard -> Encode.Value
encodeContainedObjects cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index card -> { card | id = getTTSId index })
        |> Encode.list encodeCard


encodeDeckIds : List Deck.DeckCard -> Encode.Value
encodeDeckIds cards =
    cards
        |> expandQuantities
        |> List.indexedMap (\index _ -> (index + 1) * 100)
        |> Encode.list Encode.int


expandQuantities : List Deck.DeckCard -> List Deck.DeckCard
expandQuantities cards =
    List.foldr (\card newList -> List.concat [ newList, List.repeat card.quantity card ]) [] cards


makeEncodeableDecks : Deck.Deck -> List ( List Deck.DeckCard, DeckCoords, Bool )
makeEncodeableDecks deck =
    [ ( deck.cards, firstDeckCoords, False ) ]
        ++ (if List.isEmpty deck.sideboard then
                [ ( collectDoubleFacedCardsInDeck deck, secondDeckCoords, True ) ]

            else if List.isEmpty (collectDoubleFacedCardsInDeck deck) then
                [ ( deck.sideboard, secondDeckCoords, False )
                ]

            else
                [ ( deck.sideboard, secondDeckCoords, False )
                , ( collectDoubleFacedCardsInDeck deck, thirdDeckCoords, True )
                ]
           )


collectDoubleFacedCardsInDeck : Deck.Deck -> List Deck.DeckCard
collectDoubleFacedCardsInDeck deck =
    List.concat [ deck.cards, deck.sideboard ]
        |> List.filter
            (\card ->
                case card.faces of
                    Just _ ->
                        True

                    Nothing ->
                        False
            )


encodeObjectStates : Deck.Deck -> Encode.Value
encodeObjectStates deck =
    Encode.object
        [ ( "ObjectStates"
          , Encode.list encodeDeck (makeEncodeableDecks deck)
          )
        ]


encodeCoords : DeckCoords -> Encode.Value
encodeCoords coords =
    Encode.object
        [ ( "posX", Encode.float coords.posX )
        , ( "posY", Encode.float coords.posY )
        , ( "posZ", Encode.float coords.posZ )
        , ( "rotX", Encode.float coords.rotX )
        , ( "rotY", Encode.float coords.rotY )
        , ( "rotZ", Encode.float coords.rotZ )
        , ( "scaleX", Encode.float coords.scaleX )
        , ( "scaleY", Encode.float coords.scaleY )
        , ( "scaleZ", Encode.float coords.scaleZ )
        ]


encodeDeck : ( List Deck.DeckCard, DeckCoords, Bool ) -> Encode.Value
encodeDeck ( cards, coords, doubleFaced ) =
    if List.length cards > 1 then
        Encode.object
            [ ( "Name", Encode.string "DeckCustom" )
            , ( "ContainedObjects", cards |> encodeContainedObjects )
            , ( "CustomDeck", cards |> encodeImages doubleFaced )
            , ( "DeckIDs", cards |> encodeDeckIds )
            , ( "Transform"
              , encodeCoords coords
              )
            ]

    else
        case List.head cards of
            Just card ->
                { card | id = "100" }
                    |> encodeCardFields
                    |> List.append [ ( "CustomDeck", cards |> encodeImages doubleFaced ) ]
                    |> List.map
                        (\field ->
                            if Tuple.first field == "Transform" then
                                ( "Transform", encodeCoords coords )

                            else
                                field
                        )
                    |> Encode.object

            Nothing ->
                Encode.bool False


exportDeckToTableTopSimulator : Deck.Deck -> String
exportDeckToTableTopSimulator deck =
    Encode.encode 0 (encodeObjectStates deck)
