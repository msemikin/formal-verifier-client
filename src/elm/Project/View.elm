module Project.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Material.Spinner as Loading

import Types exposing (..)
import Project.Types exposing (..)

view : Maybe Project -> Model -> Html Msg
view project { mdl } =
  div
    [ class "mdl-grid container" ]
    [ case project of
        Just project -> text project.name
        Nothing ->
          div [ class "spinner-container" ]
            [ Loading.spinner [Loading.active True]
            ]
    ]