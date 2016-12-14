module Project.View exposing (view)

import Dict
import Form exposing (Form)
import Html exposing (..)
import Html.Events
import Html.Attributes exposing (..)
import Material
import Material.Spinner as Loading
import Material.Options as Options exposing (cs, css)
import Material.Elevation as Elevation
import Material.List as List
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Textfield as Textfield
import Material.Icon as Icon
import Material.Color as Color
import Json.Encode

import Types exposing (..)
import Project.Types exposing (..)
import Helpers.Form as FormHelpers

view : Maybe Project -> Model -> Html Msg
view project { diagram, currentModelName, modelForm, mdl } =
  case project of
    Just project ->
      div [ class "project-container" ]
        [ createModelDialog modelForm mdl
        , case currentModelName of
            Nothing ->
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
            Just currentModelName ->
              case Dict.get currentModelName project.models of
                Just currentModel ->
                  div [ class "mdl-grid" ]
                    [ modelsList currentModelName project mdl
                    , div [ class "mdl-cell mdl-cell--6-col syntaxes-container" ]
                      [ modelEditor currentModel mdl
                      , formulasEditor mdl
                      ]
                    , modelGraph diagram
                    ]
                Nothing -> div [] []
          ]

    Nothing ->
      div [ class "spinner-container" ]
        [ Loading.spinner [Loading.active True]
        ]


modelEditor : LTS -> Material.Model -> Html Msg
modelEditor lts mdl =
  Options.div
    [ cs "syntax-field"
    , Elevation.e2
    ]
    [ h6 [ class "subheader" ] [ text "Model definition" ]
    , div [ class "model-editor" ]
      [ Textfield.render Mdl [1] mdl
        [ cs "model-textfield"
        , Textfield.textarea
        , Textfield.value lts.source
        ]
      ]
    ]


formulasEditor : Material.Model -> Html Msg
formulasEditor mdl =
  let
    formulas = ["First formula", "Second formula", "Third formula", "Fourth formula"]
  in
    Options.div
      [ cs "syntax-field"
      , Elevation.e2
      ]
      [ h6 [ class "subheader" ] [ text "Formulas" ]
      , div [ class "formulas-list" ]
        [ (List.ul [] <| List.indexedMap (formulaListItem mdl) formulas ++
          [ List.li
            [ cs "list-item list-item--separated"]
            [ List.content
              [ Dialog.openOn "click" ]
              [ List.icon "add" []
              , text "Create new..."
              ]
            ]
          ])
        ]
      , div [ class "formulas-footer" ]
        [ Button.render Mdl [2] mdl
          [ Button.raised
          , Button.colored
          , Button.ripple
          ]
          [ text "Run"]
        ]
      ]

formulaListItem : Material.Model -> Int -> String -> Html Msg
formulaListItem mdl index formula =
  List.li []
    [ List.content []
      [ List.icon "check" [ Color.text (Color.color Color.Green Color.S500)]
      , text formula
      ]
    , editFormula mdl index
    ]


editFormula : Material.Model -> Int -> Html Msg
editFormula mdl index =
  Button.render Mdl [10 + index] mdl
    [ Button.icon 
    ]
    [ Icon.i "edit" ] 


modelGraph : Maybe String -> Html Msg
modelGraph diagram =
  Options.div
    [ cs "mdl-cell mdl-cell--4-col model-graph"
    , Elevation.e2
    ]
    [ case diagram of
        Just diagram ->
          div [ Html.Attributes.property "innerHTML" (Json.Encode.string diagram) ]
          []
        Nothing -> div [] []
    ]


modelsList : String -> Project -> Material.Model -> Html Msg
modelsList selectedModelName project mdl =
  Options.div
    [ cs "mdl-cell mdl-cell--2-col"
    , Elevation.e2
    ]
    [ h5 [ class "list-header" ] [ text "Models" ]
    , List.ul [] <|
        (List.map (modelListItem selectedModelName) <| Dict.values project.models) ++
          [ List.li
            [ cs "list-item list-item--separated"]
            [ List.content
              [ Dialog.openOn "click" ]
              [ List.icon "add" []
              , text "Create new..."
              ]
            ]
          ]
    ]

modelListItem : String -> LTS -> Html Msg
modelListItem selectedModelName { name } =
  List.li
    [ cs <| String.join " " <|
        ["list-item"] ++ (if selectedModelName == name then ["list-item--selected"] else [])
    , Options.attribute <| Html.Events.onClick (SelectModel name) 
    ]
    [ List.content
      []
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