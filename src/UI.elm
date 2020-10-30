module UI exposing (artButton, button, dangerButton, input, successButton, textButton)

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


artButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
artButton styles =
    button ([ backgroundColor (hex "#563d7c") ] ++ styles)


dangerButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
dangerButton styles =
    button ([ backgroundColor (hex "#dc3545") ] ++ styles)


successButton : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
successButton styles =
    button ([ backgroundColor (hex "#28a745") ] ++ styles)


button : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
button styles attributes =
    styled Html.Styled.button
        ([ padding2 (px 10) (px 15)
         , borderRadius (px 4)
         , minWidth (px 100)
         , fontWeight bold
         , backgroundColor (hex "#2185d0")
         , color (hex "#ffffff")
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
         , color (hex "#000000")
         ]
            ++ styles
        )


input : List Style -> List (Attribute msg) -> List (Html msg) -> Html msg
input styles attributes =
    styled Html.Styled.input
        ([ padding2 (px 10) (px 15)
         , borderRadius (px 5)
         , border3 (px 1) solid (hex "#e3e3e3")
         ]
            ++ styles
        )
        ([] ++ attributes)
