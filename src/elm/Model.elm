module Model exposing (Model, PageData(..))

import Material
import Dict exposing (Dict)
import Http

import Types exposing (..)
import Register.Types
import Login.Types
import Profile.Types
import Project.Types

type PageData =
    RegisterData Register.Types.Model
  | LoginData Login.Types.Model
  | ProfileData Profile.Types.Model
  | ProjectData Project.Types.Model

type alias Model =
  { mdl : Material.Model
  , currentRoute : Route
  , pageData : PageData
  , user : Maybe User
  , accessToken : Maybe String
  , routeAfterLogin : Maybe Route
  , projects : Dict String Project
  }