module Profile.State exposing (init, update)

import Debug
import Material
import Maybe

import Profile.Rest exposing (..)
import Profile.Types as Types exposing (Model, Msg(..))

init : Maybe String -> ( Model, Cmd Msg )
init accessToken =
  ( { mdl = Material.model
    , projects = []
    }
  , case accessToken of
      Just accessToken -> fetchProjects accessToken
      Nothing -> Cmd.none
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
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
