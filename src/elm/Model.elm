module Model exposing (Model, PageData(..))

import Material

import Types exposing (..)
import Register.Types
import Login.Types
import Profile.Types

type PageData =
    RegisterData Register.Types.Model
  | LoginData Login.Types.Model
  | ProfileData Profile.Types.Model

type alias Model =
  { mdl : Material.Model
  , currentRoute : Route
  , pageData : PageData
  , user : Maybe User
  , accessToken : Maybe String
  }