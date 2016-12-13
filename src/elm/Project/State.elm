module Project.State exposing (..)

import Material
import Form exposing (Form)
import Form.Validate as Validate exposing (..)

import Types exposing (..)
import Project.Types exposing (..)
import Project.Rest exposing (..)
import CloseDialog exposing (..)

validate : Validation () ModelForm
validate =
  map ModelForm (field "name" string)

init : Maybe Project -> String -> String -> (Model, Cmd Msg)
init project projectId accessToken =
  let
    (currentModelIndex, loadingProject, effect) =
      case project of
        Nothing -> (Nothing, True, fetchProject projectId accessToken)
        Just project -> (Just 0, False, Cmd.none)
  in
    ( { mdl = Material.model
      , modelForm = Form.initial [] validate
      , currentModelIndex = currentModelIndex
      , projectId = projectId
      , accessToken = accessToken
      }
    , effect
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
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

      ProjectResult (Ok { models }) ->
        ( { model |
            currentModelIndex = if List.length models > 0
              then Just 0
              else Nothing
          }
        , Cmd.none
        )
     
      ProjectResult (Err _) -> ( model, Cmd.none )
     
