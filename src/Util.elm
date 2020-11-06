module Util exposing (chunk)


chunk : Int -> List a -> List (List a)
chunk size list =
    case List.take size list of
        [] ->
            []

        head ->
            head :: chunk size (List.drop size list)
