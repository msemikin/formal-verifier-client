module Project.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)

import Types exposing (Project)
import Project.Types exposing (..)

view : Model -> Html Msg
view { mdl } =
  div
    [ class "mdl-grid container" ]
    []