module Project.Types exposing (Model, Msg(..))

import Material

type alias Model =
  { mdl : Material.Model
  }

type Msg =
    Mdl (Material.Msg Msg)