module Profile.State exposing (init, update)

import Debug
import Material
import Maybe

import Profile.Types as Types exposing (Model, Msg(..))

init : ( Model, Cmd Msg )
init =
  ({ mdl = Material.model } , Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Boilerplate: Mdl action handler.
    Mdl mdlMsg ->
      Material.update mdlMsg model
