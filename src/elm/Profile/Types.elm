module Profile.Types exposing (Model, Msg(..))

import Http
import Material

import Types exposing (Project)

type alias Model =
  { mdl : Material.Model
  , projects : List Project
  }

type Msg =
    Mdl (Material.Msg Msg)
  | ProjectsResult (Result Http.Error (List Project))