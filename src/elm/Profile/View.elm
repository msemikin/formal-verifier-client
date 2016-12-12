module Profile.View exposing (view)

import Html exposing (..)
import Html.Events
import Html.Attributes exposing (class)
import Material.Options as Options exposing (cs)
import Material.Elevation as Elevation
import Material.List as List
import Material.Badge as Badge
import List

import Profile.Types exposing (Model, Msg(..))
import Types exposing (Project, Route(..))

view : Model -> Html Msg
view { mdl, projects } =
  div
    [ class "mdl-grid container" ]
    [ div [ class "mdl-cell mdl-cell--12-col" ]
      [ h4 [ class "subtitle" ] [ text "Projects" ]
      , Options.div
        [ Elevation.e2
        ]
        [ div []
          [ List.ul [] <| List.map project projects ]
        ]
      ]
    ]

project : Project -> Html Msg
project { name, description, models } =
  List.li
    [ cs "list-item"
    , List.withSubtitle
    ]
    [ List.content
      [ Options.attribute <| Html.Events.onClick (UpdateRoute LoginRoute)
      ]
      [ text name
      , List.subtitle []
        [ text description ]
      ]
    , countBadge <| List.length models
    ]

countBadge : Int -> Html Msg
countBadge count =
  Options.span
    [ Badge.add <| toString count
    ]
    []