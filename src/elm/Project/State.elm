module Project.State exposing (..)

import Debug
import Material
import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Dict

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
    (effect, currentModelName) =
      case project of
        Just project ->
          case getFirstModel project of
            Just model ->
              (Graphviz.generateDiagram model.graph, Just model.name)
            Nothing -> 
              (Cmd.none, Nothing)
        Nothing ->
          (fetchProject projectId accessToken, Nothing)
    _ = Debug.log "effect" <| toString effect
  in
    ( { mdl = Material.model
      , modelForm = Form.initial [] validateModel
      , formulaForm = Form.initial [] validateFormula
      , currentModelName = currentModelName
      , projectId = projectId
      , accessToken = accessToken
      , diagram = Nothing
      , currentDialog = ModelDialog
      }
    , effect
    )
          

update : Maybe Project -> Msg -> Model -> (Model, Cmd Msg)
update project msg model =
  let
    getModel name =
      project |> Maybe.andThen (Dict.get name << .models) 
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
      
      CreateModelResult (Ok _) -> (model, closeDialog "")

      CreateModelResult (Err _) -> (model, Cmd.none)

      ProjectResult (Ok project) ->
        case getFirstModel project of
          Just { name } -> update (Just project) (SelectModel name) model
          Nothing -> 
            ( { model | currentModelName = Nothing } , Cmd.none )
     
      ProjectResult (Err _) -> ( model, Cmd.none )

      UpdateModel source ->
        case model.currentModelName of
          Just name ->
            (model, updateModel model.projectId name source model.accessToken)
          _ -> (model, Cmd.none)

      UpdateModelResult (Ok _) -> ( model, closeDialog "" )
      UpdateModelResult (Err _) -> ( model, Cmd.none )

      AddFormula formMsg ->
        let
          newModel = updateFormulaForm formMsg
          output = Form.getOutput newModel.formulaForm
        in
          case (model.currentModelName, output) of
            (Just name, Just { content }) ->
              case getModel name of
                Just { formulas } ->
                  (newModel, patchModel model.projectId name (content :: formulas) model.accessToken)
                _ -> (model, Cmd.none)
            _ -> (newModel, Cmd.none)

      SelectModel name ->
        case getModel name of
          Just { graph } ->
            ( { model | currentModelName = Just name }
            , Graphviz.generateDiagram graph
            )
          _ -> (model, Cmd.none)
      
      DiagramGenerated diagram ->
        ( { model | diagram = Just diagram } , Cmd.none )
      
      OpenModelDialog ->
        ( { model | currentDialog = ModelDialog }, openDialog "" )
      
      OpenFormulaDialog ->
        ( { model | currentDialog = FormulaDialog }, openDialog "" )
        

subscriptions : Sub Msg
subscriptions =
  Graphviz.diagramResult DiagramGenerated
