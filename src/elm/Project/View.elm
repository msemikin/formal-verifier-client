module Project.View exposing (view)

import Dict
import Form exposing (Form)
import Html exposing (..)
import Html.Events exposing (onInput)
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
import Material.Tabs as Tabs
import Json.Encode

import Types exposing (..)
import Project.Types exposing (..)
import Helpers.Form as FormHelpers

view : Maybe Project -> Model -> Html Msg
view project
  { diagram
  , currentModelId
  , modelForm
  , formulaForm
  , mdl
  , currentDialog
  , currentTab
  , modelSource
  } =
    case project of
      Just project ->
        div [ class "project-container" ]
          [ case currentDialog of
              ModelDialog -> createModelDialog modelForm mdl
              FormulaDialog -> createFormulaDialog formulaForm mdl
          , case currentModelId of
              Nothing ->
                div [ class "empty-project" ]
                  [ p [] [ text "You should create your first model" ]
                  , Button.render Mdl [0] mdl
                    [ Button.raised
                    , Button.colored
                    , Button.ripple
                    , Button.onClick OpenModelDialog
                    ]
                    [ text "Create model"]
                  ]
              Just modelId ->
                case (Dict.get modelId project.models, modelSource) of
                  (Just currentModel, Just modelSource) ->
                    div [ class "mdl-grid" ]
                      [ modelsList modelId project mdl
                      , Options.div
                        [ cs "mdl-cell mdl-cell--6-col tabs-container"
                        , Elevation.e2
                        ]
                        [ Tabs.render Mdl [0] mdl
                          [ Tabs.ripple
                          , Tabs.onSelectTab SelectTab
                          , Tabs.activeTab currentTab
                          ]
                          [ Tabs.label 
                              [ Options.center ] 
                              [ Icon.i "input"
                              , Options.span [ css "width" "4px" ] []
                              , text "Model definition" 
                              ]
                          , Tabs.label 
                              [ Options.center ] 
                              [ Icon.i "functions"
                              , Options.span [ css "width" "4px" ] []  
                              , text "Formulas" 
                              ]
                          ]
                          [ case currentTab of
                              0 -> modelEditor modelSource mdl
                              _ -> formulasEditor mdl currentModel.formulas
                          ]
                        ]
                      , modelGraph diagram
                      ]
                  _ -> div [] []
            ]

      Nothing ->
        div [ class "spinner-container" ]
          [ Loading.spinner [Loading.active True]
          ]


modelEditor : String -> Material.Model -> Html Msg
modelEditor source mdl =
  div [ class "tab-content" ]
    [ div [ class "model-editor" ]
      [ textarea
        [ class "model-textfield", value source
        , onInput UpdateModelSource
        ]
        [ ]
      ]
    , div [ class "formulas-footer" ]
      [ Button.render Mdl [1] mdl
        [ Button.raised
        , Button.colored
        , Button.ripple
        , Button.onClick UpdateModel
        ]
        [ text "Save"]
      ]
    ]


formulasEditor : Material.Model -> List String -> Html Msg
formulasEditor mdl formulas =
  div [ class "tab-content" ]
    [ div [ class "formulas-list" ]
      [ if List.length formulas == 0
          then p [ class "no-formulas" ] [ text "No formulas added yet!" ]
          else div [] []
      , (List.ul [] <| List.indexedMap (formulaListItem mdl) formulas ++
        [ List.li
          [ cs "list-item list-item--separated"
          , Options.attribute <| Html.Events.onClick OpenFormulaDialog
          ]
          [ List.content []
            [ List.icon "add" []
            , text "Add new..."
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
  List.li [ cs "list-item" ]
    [ List.content []
      [ List.icon "check" [ Color.text (Color.color Color.Green Color.S500)]
      , text formula
      ]
    , editFormula mdl index
    ]


editFormula : Material.Model -> Int -> Html Msg
editFormula mdl index =
  Button.render Mdl [10000 + index] mdl
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
modelsList selectedModelId project mdl =
  Options.div
    [ cs "mdl-cell mdl-cell--2-col"
    , Elevation.e2
    ]
    [ h5 [ class "list-header" ] [ text "Models" ]
    , List.ul [] <|
        (List.map (modelListItem selectedModelId) <| Dict.values project.models) ++
          [ List.li
            [ cs "list-item list-item--separated"
            , Options.attribute <| Html.Events.onClick OpenModelDialog
            ]
            [ List.content []
              [ List.icon "add" []
              , text "Create new..."
              ]
            ]
          ]
    ]

modelListItem : String -> LTS -> Html Msg
modelListItem selectedModelId { id, name } =
  List.li
    [ cs <| String.join " " <|
        ["list-item"] ++ (if selectedModelId == id then ["list-item--selected"] else [])
    , Options.attribute <| Html.Events.onClick (SelectModel id) 
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
    connectField = FormHelpers.connectField ModelFormMsg form
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
        [ Button.render Mdl [3] mdl
          [ Button.colored
          , Button.onClick <| CreateModel Form.Submit
          ]
          [ text "Create" ]
        , Button.render Mdl [4] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]

createFormulaDialog : Form e o -> Material.Model -> Html Msg
createFormulaDialog form mdl =
  let
    getField = FormHelpers.getField form
    getFieldValue = FormHelpers.getFieldValue form
    connectField = FormHelpers.connectField FormulaFormMsg form
    getError = FormHelpers.getError form
  in
    Dialog.view []
      [ Dialog.title [] [ text "New formula" ]
      , Dialog.content []
        [ div []
          [ Textfield.render Mdl [0] mdl
            ([ Textfield.label "Content"
            , Textfield.floatingLabel
            , cs "field"
            , getError "content" "Content is required"
            ] ++ connectField "content")
          ]
        ]
      , Dialog.actions []
        [ Button.render Mdl [5] mdl
          [ Button.colored
          , Button.onClick <| AddFormula Form.Submit
          ]
          [ text "Create" ]
        , Button.render Mdl [6] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]