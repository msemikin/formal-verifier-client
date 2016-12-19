module Register.Types exposing (RegistrationForm, Model, Msg(..))

import Material
import Types exposing (User)
import Form exposing (Form)
import Http

type alias RegistrationForm =
  { firstName: String
  , lastName: String
  , username: String
  , email: String
  , password: String
  , passwordRepeat: String
  }

type alias Model =
  { mdl : Material.Model
  , registrationForm: Form () RegistrationForm
  }

type Msg =
    Mdl (Material.Msg Msg)
  | FormMsg (Form.Msg)
  | Register (Form.Msg)
  | RegisterResult (Result Http.Error { user : User, accessToken : String })
