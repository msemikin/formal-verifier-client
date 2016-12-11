module Model exposing (Model)

import Navigation
import Material

import Types exposing (User)
import Register.Types as RegisterTypes
import Routing exposing (..)

type alias Model =
  { mdl : Material.Model
  , history: List Route
  , user : Maybe User
  , register : RegisterTypes.Model
  }