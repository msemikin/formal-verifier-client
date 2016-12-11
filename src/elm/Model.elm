module Model exposing (Model)

import Navigation
import Material
import Types exposing (User)
import Register.Types as RegisterTypes

type alias Model =
  { mdl : Material.Model
  , history: List Navigation.Location
  , user : Maybe User
  , register : RegisterTypes.Model
  }