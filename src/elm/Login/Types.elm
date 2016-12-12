module Login.Types exposing (LoginForm, Model, Msg(..))

import Material
import Types exposing (LoginResponse, User)
import Form exposing (Form)
import Http

type alias LoginForm =
  { username: String
  , password: String
  }

type alias Model =
  { mdl : Material.Model
  , loginForm: Form () LoginForm
  }

type Msg =
    Mdl (Material.Msg Msg)
  | FormMsg (Form.Msg)
  | Login (Form.Msg)
  | LoginResult (Result Http.Error LoginResponse)

