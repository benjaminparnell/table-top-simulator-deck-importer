module UI exposing (artButton, button, colors, dangerButton, input, successButton, textButton)

import Css
    exposing
        ( Style
        , backgroundColor
        , bold
        , border
        , border3
        , borderBottom2
        , borderLeft
        , borderRadius
        , borderRight
        , borderTop
        , color
        , fontWeight
        , hex
        , marginBottom
        , minWidth
        , outline
        , padding2
        , px
        , solid
        , transparent
        , zero
        )
import Html.Styled exposing (Attribute, Html, styled)
import Msg


type alias Colors =
    { red : String
    , blue : String
    , purple : String
    , green : String
    , black : String
    , grey : String
    , white : String
    }


colors : Colors
colors =
    Colors "#dc3545" "#2185d0" "#563d7c" "#28a745" "#000000" "#e3e3e3" "#ffffff"


artButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
artButton styles =
    button ([ backgroundColor (hex colors.purple) ] ++ styles)


dangerButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
dangerButton styles =
    button ([ backgroundColor (hex colors.red) ] ++ styles)


successButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
successButton styles =
    button ([ backgroundColor (hex colors.green) ] ++ styles)


button : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
button styles attributes =
    styled Html.Styled.button
        ([ padding2 (px 10) (px 15)
         , borderRadius (px 4)
         , minWidth (px 100)
         , fontWeight bold
         , backgroundColor (hex colors.blue)
         , color (hex colors.white)
         , border zero
         ]
            ++ styles
        )
        ([] ++ attributes)


textButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
textButton styles =
    button
        ([ borderBottom2 (px 3) solid
         , borderTop zero
         , borderLeft zero
         , borderRight zero
         , backgroundColor transparent
         , color (hex colors.black)
         ]
            ++ styles
        )


input : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
input styles attributes =
    styled Html.Styled.input
        ([ padding2 (px 10) (px 15)
         , borderRadius (px 5)
         , border3 (px 1) solid (hex colors.grey)
         ]
            ++ styles
        )
        ([] ++ attributes)
