module Project.State exposing (..)

import Debug
import Material
import Form exposing (Form)
import Form.Field
import Form.Validate as Validate exposing (..)
import Dict
import Http exposing (Error(..))
import Json.Decode as Decode exposing (decodeString)

import Types exposing (..)
import Project.Types exposing (..)
import Project.Rest exposing (..)
import Dialog exposing (..)
import Graphviz

validateModel : Validation () ModelForm
validateModel =
  map ModelForm (field "name" string)

validateFormula : Validation () FormulaForm
validateFormula =
  map FormulaForm (field "content" string)

getFirstModel : Project -> Maybe LTS
getFirstModel project =
  Dict.values project.models
    |> List.head

init : Maybe Project -> String -> String -> (Model, Cmd Msg)
init project projectId accessToken =
  let
    (effect, currentModelId, modelSource) =
      case project of
        Just project ->
          case getFirstModel project of
            Just model ->
              ( Cmd.batch
                [ Graphviz.generateDiagram model.graph
                , checkModel projectId model.id accessToken
                ]
              , Just model.id, Just model.source
              )

            Nothing -> 
              (Cmd.none, Nothing, Nothing)
        Nothing ->
          (fetchProject projectId accessToken, Nothing, Nothing)
  in
    ( { mdl = Material.model
      , modelForm = Form.initial [] validateModel
      , formulaForm = Form.initial [] validateFormula
      , currentModelId = currentModelId
      , projectId = projectId
      , accessToken = accessToken
      , diagram = Nothing
      , currentDialog = ModelDialog
      , currentTab = 0
      , modelSource = modelSource
      , formulasResults = Nothing
      , currentFormula = Nothing
      , syntaxError = Nothing
      }
    , effect
    )

update : Maybe Project -> Msg -> Model -> (Model, Cmd Msg)
update project msg model =
  let
    getModel id =
      project |> Maybe.andThen (Dict.get id << .models) 
    updateModelForm formMsg =
      { model | modelForm = Form.update formMsg model.modelForm }
    updateFormulaForm formMsg =
      { model | formulaForm = Form.update formMsg model.formulaForm }
  in
    case msg of
      Mdl mdlMsg ->
        Material.update mdlMsg model
      
      ModelFormMsg formMsg -> (updateModelForm formMsg, Cmd.none)
      
      FormulaFormMsg formMsg -> (updateFormulaForm formMsg, Cmd.none)
      
      CreateModel formMsg ->
        let
          newModel = updateModelForm formMsg
          output = Form.getOutput newModel.modelForm
        in
          case output of
            Just formData ->
              (newModel, createModel model.projectId formData model.accessToken)
            Nothing -> (newModel, Cmd.none)
      
      CreateModelResult (Ok { id }) ->
        let
          (updatedModel, effect) = 
            update project (SelectModel id) model
        in
          (updatedModel, Cmd.batch [closeDialog "", effect])

      CreateModelResult (Err _) -> (model, Cmd.none)

      ProjectResult (Ok project) ->
        case getFirstModel project of
          Just { id, source } ->
            update (Just project) (SelectModel id) { model | modelSource = Just source }
          Nothing -> 
            ( { model | currentModelId = Nothing } , Cmd.none )
      
      ProjectResult (Err _) -> ( model, Cmd.none )

      UpdateModel ->
        case (model.currentModelId, model.modelSource) of
          (Just modelId, Just modelSource) ->
            (model, updateModel model.projectId modelId modelSource model.accessToken)
          _ -> (model, Cmd.none)

      UpdateModelResult (Ok { graph }) ->
        let
          (updatedModel, effect) =
            update project CheckModel model
        in
          ( { updatedModel | syntaxError = Nothing }
          , Cmd.batch
            [ Graphviz.generateDiagram graph
            , closeDialog ""
            , effect
            ]
          )

      UpdateModelResult (Err (BadStatus response)) ->
        case decodeString (Decode.field "message" Decode.string) response.body of
          Ok syntaxError -> ( { model | syntaxError = Just syntaxError }, Cmd.none)
          Err _ -> ( model, Cmd.none )
      
      UpdateModelResult (Err _) -> ( model, Cmd.none )

      AddFormula formMsg ->
        let
          newModel = updateFormulaForm formMsg
          output = Form.getOutput newModel.formulaForm
        in
          case (model.currentModelId, output) of
            (Just modelId, Just { content }) ->
              case getModel modelId of
                Just { formulas } ->
                  (newModel, patchModel model.projectId modelId (content :: formulas) model.accessToken)
                _ -> (model, Cmd.none)
            _ -> (newModel, Cmd.none)

      SelectModel id ->
        let
          _ = Debug.log "" ("in SelectModel " ++ (toString <| getModel id) ++ " " ++ toString project)
        in
          case getModel id of
            Just { source, graph } ->
              let
                modelWithSelectedModel =
                  { model | currentModelId = Just id, modelSource = Just source }
                (updatedModel, effect) = update project CheckModel modelWithSelectedModel
                _ = Debug.log "effect" <| toString effect
              in
                ( updatedModel
                , Cmd.batch [Graphviz.generateDiagram graph, effect]
                )
            _ -> (model, Cmd.none)
      
      DiagramGenerated diagram ->
        ( { model | diagram = Just diagram } , Cmd.none )
      
      OpenModelDialog ->
        ( { model |
            currentDialog = ModelDialog
          , modelForm = Form.initial [] validateModel
          }
          , openDialog ""
        )
      
      OpenAddFormula ->
        ( { model |
            formulaForm = Form.initial [] validateFormula
          , currentDialog = AddFormulaDialog
          }
          , openDialog ""
        )
      
      SelectTab tab ->
        ( { model | currentTab = tab }, Cmd.none )
      
      UpdateModelSource source ->
        ( { model | modelSource = Just source }, Cmd.none )
      
      CheckModel ->
        case model.currentModelId of
          Just currentModelId ->
            ( model, checkModel model.projectId currentModelId model.accessToken  )
          Nothing -> ( model, Cmd.none )
      
      CheckModelResult (Ok formulasResults) ->
        case Dict.toList formulasResults |> List.head of
          Just ( formula, graph ) ->
            update project (SelectFormula formula)
              { model | formulasResults = Just formulasResults }

          Nothing -> ( model, Cmd.none )

      CheckModelResult (Err _) -> ( model, Cmd.none )
        
      SelectFormula formula ->
        case model.formulasResults |> Maybe.andThen (Dict.get formula) of
          Just { graph } ->
            ( { model |
                currentFormula = Just formula
              }
            , Graphviz.generateDiagram graph
            )
          Nothing -> ( model, Cmd.none )

      EditFormula formula ->
        let
          withUpdatedForm = updateFormulaForm
            (Form.Input "content" Form.Text (Form.Field.String formula))
          (updatedModel, effect) = update project (SelectFormula formula) withUpdatedForm
        in
          ( { updatedModel | currentDialog = EditFormulaDialog }
          , Cmd.batch [openDialog "", effect]
          )

      UpdateFormula formMsg -> 
        let
          newModel = updateFormulaForm formMsg
          output = Form.getOutput newModel.formulaForm
        in
          case (model.currentModelId, output, model.currentFormula) of
            (Just modelId, Just { content }, Just currentFormula) ->
              case getModel modelId of
                Just { formulas } ->
                  ( newModel
                  , patchModel
                      model.projectId
                      modelId
                      ( formulas |> List.map
                          (\f -> if f == currentFormula then content else f)
                      )
                      model.accessToken
                  )
                _ -> (model, Cmd.none)
            _ -> (newModel, Cmd.none)

      DeleteFormula formula ->
        case (model.currentModelId) of
          Just modelId ->
            case getModel modelId of
              Just { formulas } ->
                ( model
                , patchModel
                    model.projectId
                    modelId
                    ( formulas |> List.filter ((/=) formula))
                    model.accessToken
                )
              _ -> (model, Cmd.none)
          _ -> (model, Cmd.none)
      
      DeleteModel modelId ->
        (model, deleteModel model.projectId modelId model.accessToken)
      

      DeleteModelResult (Ok success) _ ->
        ( { model | currentModelId = project |> Maybe.andThen getFirstModel |> Maybe.map .id }
        , Cmd.none
        )
      
      DeleteModelResult (Err _) _ -> (model, Cmd.none)


subscriptions : Sub Msg
subscriptions =
  Graphviz.diagramResult DiagramGenerated
