module Project.View exposing (view)

import Dict
import Form exposing (Form)
import Html exposing (..)
import Html.Attributes exposing (class)
import Material
import Material.Spinner as Loading
import Material.Options as Options exposing (cs, css)
import Material.Elevation as Elevation
import Material.List as List
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Textfield as Textfield

import Types exposing (..)
import Project.Types exposing (..)
import Helpers.Form as FormHelpers

view : Maybe Project -> Model -> Html Msg
view project { modelForm, mdl } =
  case project of
    Just project ->
      div [ class "project-container" ]
        [ createModelDialog modelForm mdl
        , if Dict.size project.models == 0
            then
              div [ class "empty-project" ]
                [ p [] [ text "You should create your first model" ]
                , Button.render Mdl [0] mdl
                  [ Button.raised
                  , Button.colored
                  , Button.ripple
                  , Dialog.openOn "click"
                  ]
                  [ text "Create model"]
                ]
            else
              div [ class "mdl-grid" ]
                [ Options.div
                  [ cs "mdl-cell mdl-cell--2-col"
                  , Elevation.e2
                  ]
                  [ h5 [ class "list-header" ] [ text "Models" ]
                  , List.ul [] <|
                      (List.map model <| Dict.values project.models) ++
                        [ List.li
                          [ cs "list-item--separated" ]
                          [ List.content
                            [ Dialog.openOn "click" ]
                            [ List.icon "add" []
                            , text "Create new..."
                            ]
                          ]
                        ]
                  ]

                , div [ class "mdl-cell mdl-cell--6-col syntaxes-container" ]
                  [ Options.div
                    [ cs "syntax-field"
                    , Elevation.e2
                    ]
                    []

                  , Options.div
                    [ cs "syntax-field"
                    , Elevation.e2
                    ]
                    []
                  ]
                ]
          ]

    Nothing ->
      div [ class "spinner-container" ]
        [ Loading.spinner [Loading.active True]
        ]


model : LTS -> Html Msg
model { name } =
  List.li
    [ ]
    [ List.content []
      [ text name ]
    ]

createModelDialog : Form e o -> Material.Model -> Html Msg
createModelDialog form mdl =
  let
    getField = FormHelpers.getField form
    getFieldValue = FormHelpers.getFieldValue form
    connectField = FormHelpers.connectField FormMsg form
    getError = FormHelpers.getError form
  in
    Dialog.view []
      [ Dialog.title [] [ text "New model" ]
      , Dialog.content []
        [ div []
          [ Textfield.render Mdl [0] mdl
            ([ Textfield.label "Name"
            , Textfield.floatingLabel
            , cs "field"
            , getError "name" "Name is required"
            ] ++ connectField "name")
          ]
        ]
      , Dialog.actions []
        [ Button.render Mdl [1] mdl
          [ Button.colored
          , Button.onClick <| CreateModel Form.Submit
          ]
          [ text "Create" ]
        , Button.render Mdl [0] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]