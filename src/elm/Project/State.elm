module Project.State exposing (..)

import Material

import Project.Types exposing (..)

init : (Model, Cmd Msg)
init =
  ( { mdl = Material.model
    }
  , Cmd.none
  )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Mdl mdlMsg ->
      Material.update mdlMsg model