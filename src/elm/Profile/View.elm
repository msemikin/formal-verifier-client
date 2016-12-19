module Profile.View exposing (view)

import Html exposing (..)
import Html.Events
import Html.Attributes exposing (class)
import Material
import Material.Options as Options exposing (cs)
import Material.Elevation as Elevation
import Material.List as List
import Material.Badge as Badge
import Material.Button as Button
import Material.Icon as Icon
import Material.Dialog as Dialog
import Dict

import Profile.Types exposing (Model, Msg(..))
import Types exposing (Project, Route(..))
import CreateProjectDialog.View

view : List Project ->  Model -> Html Msg
view projects { mdl, projectForm } =
  div
    [ class "mdl-grid container" ]
    [ div [ class "mdl-cell mdl-cell--12-col" ]
      [ h4 [ class "subtitle" ] [ text "Projects" ]
      , Options.div
        [ Elevation.e2
        ]
        [ if List.length projects == 0
            then
              p [ class "no-projects" ] [ text "No projects created yet!" ]
            else
              div []
                [ List.ul [] <| List.indexedMap (project mdl) projects ]
        ]
      , Button.render Mdl [0] mdl
        [ Button.fab
        , Button.colored
        , Button.ripple
        , cs "btn-add-project"
        , Dialog.openOn "click"
        ]
        [ Icon.i "add"]
      , CreateProjectDialog.View.view projectForm mdl
      ]
    ]

project : Material.Model -> Int -> Project -> Html Msg
project mdl index { id, name, description, models } =
  List.li
    [ cs "list-item"
    , List.withSubtitle
    ]
    [ List.content
      [ Options.attribute <| Html.Events.onClick (UpdateRoute <| ProjectRoute id)
      ]
      [ text name
      , List.subtitle []
        [ text description ]
      ]
    , deleteProject mdl index id
    , countBadge <| Dict.size models
    ]

deleteProject : Material.Model -> Int -> String -> Html Msg
deleteProject mdl index projectId =
  Button.render Mdl [index] mdl
    [ Button.icon 
    , Button.onClick <| DeleteProject projectId
    ]
    [ Icon.i "delete" ] 


countBadge : Int -> Html Msg
countBadge count =
  Options.span
    [ Badge.add <| toString count
    ]
    []