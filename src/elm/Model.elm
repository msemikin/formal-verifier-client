module Model exposing (Model)

import Material

import Types exposing (User)
import Register.Types
import Login.Types
import Profile.Types
import Routing exposing (..)

type alias Model =
  { mdl : Material.Model
  , history : List Route
  , user : Maybe User
  , accessToken : Maybe String
  , register : Register.Types.Model
  , login : Login.Types.Model
  , profile : Profile.Types.Model
  }