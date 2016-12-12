module Messages exposing (Msg(..))

import Http
import Material

import Types exposing (..)
import Register.Types
import Login.Types
import Profile.Types
import Project.Types

type Msg =
    Mdl (Material.Msg Msg)
  | UpdateRoute Route

  | RegisterMsg Register.Types.Msg
  | LoginMsg Login.Types.Msg
  | ProfileMsg Profile.Types.Msg
  | ProjectMsg Project.Types.Msg

  | AccessTokenResult String
  | SilentLoginResult (Result Http.Error User)
