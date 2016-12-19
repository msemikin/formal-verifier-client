module Project.View exposing (view)

import Dict exposing (Dict)
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
import Material.Menu as Menu
import Json.Encode

import Types exposing (..)
import Project.Types exposing (..)
import Helpers.Form as FormHelpers
import Dropdown.View
import Dropdown.Types

view : Maybe Project -> Model -> Html Msg
view project
  { diagram
  , currentModelId
  , modelForm
  , formulaForm
  , composeForm
  , mdl
  , currentDialog
  , currentTab
  , modelSource
  , syntaxError
  , formulasResults
  , currentFormula
  , composeModelFirst
  , composeModelSecond
  , firstDropdown
  , secondDropdown
  } =
    case project of
      Just project ->
        div [ class "project-container" ]
          [ case currentDialog of
              ModelDialog -> createModelDialog syntaxError modelForm mdl
              ComposeDialog -> composeDialog
                  firstDropdown
                  secondDropdown
                  composeForm
                  (Dict.values project.models)
                  (composeModelFirst |> Maybe.andThen (\id -> Dict.get id project.models))
                  (composeModelSecond |> Maybe.andThen (\id -> Dict.get id project.models))
                  mdl
              _ -> createFormulaDialog currentDialog syntaxError formulaForm mdl
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
                              _ -> formulasEditor
                                mdl currentModel.formulas formulasResults currentFormula
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

formulasEditor : Material.Model -> List String -> Maybe (Dict String ValidationResult) -> Maybe String -> Html Msg
formulasEditor mdl formulas validations currentFormula =
  div [ class "tab-content" ]
    [ div [ class "formulas-list" ]
      [ if List.length formulas == 0
          then p [ class "no-formulas" ] [ text "No formulas added yet!" ]
          else div [] []
      , (List.ul []
          <| (List.indexedMap
            (\i f -> formulaListItem mdl i f
              (currentFormula |> Maybe.map ((==) f) |> Maybe.withDefault False)
              (validations |> Maybe.andThen (Dict.get f))
            )
            formulas
          ) ++
          [ List.li
            [ cs "list-item list-item--separated"
            , Options.attribute <| Html.Events.onClick OpenAddFormula
            ]
            [ List.content []
              [ List.icon "add" []
              , text "Add new..."
              ]
            ]
          ])
      ]
    ]

formulaListItem : Material.Model -> Int -> String -> Bool -> Maybe ValidationResult -> Html Msg
formulaListItem mdl index formula isSelected validation =
  List.li
    [ cs <| String.join " " <| ["list-item"] ++ if isSelected then ["list-item--selected"] else []
    , Options.attribute <| Html.Events.onClick (SelectFormula formula) 
    ]
    [ List.content []
      [ case validation of
          Just { valid } ->
            if valid
              then
                List.icon "check" [ Color.text (Color.color Color.Green Color.S500)]
              else
                List.icon "error" [ Color.text (Color.color Color.Red Color.S500)]
          Nothing ->
            List.icon "question" [ Color.text (Color.color Color.Red Color.S500)]
      , text formula
      ]
    , editFormula mdl index formula
    , deleteFormula mdl index formula
    ]


editFormula : Material.Model -> Int -> String -> Html Msg
editFormula mdl index formula =
  Button.render Mdl [10000 + index] mdl
    [ Button.icon 
    , Button.onClick <| EditFormula formula
    ]
    [ Icon.i "edit" ] 


deleteFormula : Material.Model -> Int -> String -> Html Msg
deleteFormula mdl index formula =
  Button.render Mdl [20000 + index] mdl
    [ Button.icon 
    , Button.onClick <| DeleteFormula formula
    ]
    [ Icon.i "delete" ] 


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
        (List.indexedMap (modelListItem mdl selectedModelId)
          <| Dict.values project.models
        ) ++
          [ List.li
            [ cs "list-item list-item--separated" , Options.attribute <| Html.Events.onClick OpenModelDialog
            ]
            [ List.content []
              [ List.icon "add" []
              , text "Create new..."
              ]
            ]
          , List.li
            [ cs "list-item" , Options.attribute <| Html.Events.onClick OpenComposeDialog
            ]
            [ List.content []
              [ List.icon "add" []
              , text "Compose"
              ]
            ]
          ]
    ]

modelListItem : Material.Model -> String -> Int -> LTS -> Html Msg
modelListItem mdl selectedModelId index { id, name } =
  List.li
    [ cs <| String.join " " <|
        ["list-item"] ++ (if selectedModelId == id then ["list-item--selected"] else [])
    , Options.attribute <| Html.Events.onClick (SelectModel id) 
    ]
    [ List.content
      []
      [ text name ]
    , deleteModel mdl index id
    ]


deleteModel : Material.Model -> Int -> String -> Html Msg
deleteModel mdl index modelId =
  Button.render Mdl [30000 + index] mdl
    [ Button.icon 
    , Button.onClick <| DeleteModel modelId
    ]
    [ Icon.i "delete" ] 


createModelDialog : Maybe String -> Form e o -> Material.Model -> Html Msg
createModelDialog syntaxError form mdl =
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
            , case syntaxError of
                Just error -> Textfield.error error
                Nothing -> Options.nop
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

createFormulaDialog : CurrentDialog -> Maybe String -> Form e o -> Material.Model -> Html Msg
createFormulaDialog currentDialog syntaxError form mdl =
  let
    getField = FormHelpers.getField form
    getFieldValue = FormHelpers.getFieldValue form
    connectField = FormHelpers.connectField FormulaFormMsg form
    getError = FormHelpers.getError form
  in
    Dialog.view []
      [ Dialog.title []
      [ text (case currentDialog of
          AddFormulaDialog -> "Add formula"
          EditFormulaDialog -> "Edit formula"
          _ -> "Should not reach"
        )
      ]
      , Dialog.content [] [ div []
          [ Textfield.render Mdl [0] mdl
            ([ Textfield.label "Content"
            , Textfield.floatingLabel
            , cs "field"
            , getError "content" "Content is required"
            , case syntaxError of
                Just error -> Textfield.error error
                Nothing -> Options.nop
            ] ++ connectField "content")
          ]
        ]
      , Dialog.actions []
        [ case currentDialog of
          AddFormulaDialog ->
            Button.render Mdl [5] mdl
            [ Button.colored
            , Button.onClick (AddFormula Form.Submit)
            ]
            [ text "Create" ]
          _ ->
            Button.render Mdl [5] mdl
            [ Button.colored
            , Button.onClick (UpdateFormula Form.Submit)
            ]
            [ text "Update" ]

        , Button.render Mdl [6] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]

composeDialog : Dropdown.Types.Model -> Dropdown.Types.Model -> Form e o -> List LTS -> Maybe LTS -> Maybe LTS -> Material.Model -> Html Msg
composeDialog firstDropdown secondDropdown form models firstComposeModel secondComposeModel mdl =
  let
    getField = FormHelpers.getField form
    getFieldValue = FormHelpers.getFieldValue form
    connectField = FormHelpers.connectField ComposeFormMsg form
    getError = FormHelpers.getError form
  in
    Dialog.view [ cs "compose-dialog" ]
      [ Dialog.title []
        [ text "Compose models" ]
      , Dialog.content [] [ div []
          [ Textfield.render Mdl [0] mdl
            ([ Textfield.label "Name"
            , Textfield.floatingLabel
            , cs "field"
            , getError "name" "Name is required"
            ] ++ connectField "name")
          , Html.map
              FirstDropdownMsg
              (Dropdown.View.view models firstComposeModel firstDropdown)
          , Html.map
              SecondDropdownMsg
              (Dropdown.View.view models secondComposeModel secondDropdown)
          ]
        ]
      , Dialog.actions []
        [ Button.render Mdl [5] mdl
          [ Button.colored
          , Button.onClick (ComposeModels Form.Submit)
          ]
          [ text "Create" ]
        , Button.render Mdl [6] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]
    
 