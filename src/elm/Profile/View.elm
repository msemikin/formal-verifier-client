module Profile.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Material.Options as Options exposing (cs)
import Material.Elevation as Elevation
import Material.List as List
import List

import Profile.Types exposing (Model, Msg)

view : Model -> Html Msg
view { mdl } =
  let 
    projects = List.range 1 10
  in
    div
      [ class "mdl-grid container" ]
      [ div [ class "mdl-cell mdl-cell--12-col" ]
        [ h4 [ class "subtitle" ] [ text "Projects" ]
        , Options.div
            [ Elevation.e2
            ]
            [ div []
                [ List.ul []
                    (List.map
                      (\i ->
                        List.li
                          [ cs "list-item"
                          , List.withSubtitle
                          ]
                          [ List.content []
                            [ text "Project 1"
                            , List.subtitle []
                              [ text "Some project description" ]
                            ]
                          ]
                      )
                      projects
                    )
                ]
            ]
        ]
      ]
