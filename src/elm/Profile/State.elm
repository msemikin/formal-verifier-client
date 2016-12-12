module Profile.State exposing (init, update)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Debug
import Material
import Maybe

import Profile.Rest exposing (..)
import Profile.Types as Types exposing (..)

validate : Validation () ProjectForm
validate =
  map2 ProjectForm
    (field "name" string)
    (field "description" string)

init : Maybe String -> ( Model, Cmd Msg )
init accessToken =
  ( { mdl = Material.model
    , projects = []
    , projectForm = Form.initial [] validate
    }
  , case accessToken of
      Just accessToken -> fetchProjects accessToken
      Nothing -> Cmd.none
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
      
      ProjectsResult (Ok projects) ->
        ( { model | projects = projects }
        , Cmd.none
        )
      
      ProjectsResult (Err _) ->
        (model, Cmd.none)
      
      UpdateRoute _ -> (model, Cmd.none)

      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)
      
      CreateProject formMsg ->
        let
          newModel = updateForm formMsg
          output = Form.getOutput newModel.projectForm
          _ = Debug.log "output" <| toString newModel.projectForm
        in
          case output of
            Just formData -> (newModel, createProject formData accessToken)
            Nothing -> (newModel, Cmd.none)
      
      CreateProjectResult (Ok project) ->
        ( { model | projects = model.projects ++ [project] }
        , Cmd.none
        )

      CreateProjectResult (Err _) -> (model, Cmd.none)
