module Project.State exposing (..)

import Debug
import Material
import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Dict

import Types exposing (..)
import Project.Types exposing (..)
import Project.Rest exposing (..)
import CloseDialog exposing (..)
import Graphviz

validate : Validation () ModelForm
validate =
  map ModelForm (field "name" string)


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
      , modelForm = Form.initial [] validate
      , currentModelName = currentModelName
      , projectId = projectId
      , accessToken = accessToken
      , diagram = Nothing
      }
    , effect
    )
          

update : Maybe Project -> Msg -> Model -> (Model, Cmd Msg)
update project msg model =
  let
    updateForm formMsg =
      { model | modelForm = Form.update formMsg model.modelForm }
  in
    case msg of
      Mdl mdlMsg ->
        Material.update mdlMsg model
      
      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)
      
      CreateModel formMsg ->
        let
          newModel = updateForm formMsg
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

      UpdateModelResult _ -> ( model, Cmd.none )

      SelectModel name ->
        case (project |> Maybe.andThen (Dict.get name << .models)) of
          Just { graph } ->
            ( { model | currentModelName = Just name }
            , Graphviz.generateDiagram graph
            )
          _ -> (model, Cmd.none)
      
      DiagramGenerated diagram ->
        ( { model | diagram = Just diagram } , Cmd.none )
        

subscriptions : Sub Msg
subscriptions =
  Graphviz.diagramResult DiagramGenerated
