module Profile.View exposing (view)

import Html exposing (..)
import Messages exposing (Msg(..))

view : Html Msg
view =
    div []
        [ text "Profile page"
        ]