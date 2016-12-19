module Profile.State exposing (init, update)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Material
import Maybe

import Profile.Types as Types exposing (..)
import Dialog exposing (..)
import Profile.Rest exposing (..)

validate : Validation () ProjectForm
validate =
  map2 ProjectForm
    (field "name" string)
    (field "description" string)

init : ( Model, Cmd Msg )
init =
  ( { mdl = Material.model
    , projectForm = Form.initial [] validate
    }
  , Cmd.none
  )

update : String -> Msg -> Model -> (Model, Cmd Msg)
update accessToken msg model =
  let
    updateForm formMsg =
      { model | projectForm = Form.update formMsg model.projectForm }
  in
    case msg of
      -- Boilerplate: Mdl action handler.
      Mdl mdlMsg ->
        Material.update mdlMsg model
      
      UpdateRoute _ -> (model, Cmd.none)

      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)
      
      CreateProject formMsg ->
        let
          newModel = updateForm formMsg
          output = Form.getOutput newModel.projectForm
        in
          case output of
            Just formData -> (newModel, createProject formData accessToken)
            Nothing -> (newModel, Cmd.none)
      
      CreateProjectResult (Ok project) ->
        ( { model | projectForm = Form.initial [] validate }
        , closeDialog ""
        )

      CreateProjectResult (Err _) -> (model, Cmd.none)

      DeleteProject projectId ->
        ( model, deleteProject projectId accessToken )
      
      DeleteProjectResult (Ok _) _ ->
        ( { model | projectForm = Form.initial [] validate } , Cmd.none)

      DeleteProjectResult (Err _) _ ->
        (model, Cmd.none)
