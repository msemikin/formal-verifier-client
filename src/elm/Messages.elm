module Messages exposing (Msg(..))

import Navigation
import Material

import Register.Types
import Login.Types
import Profile.Types

type Msg =
    Mdl (Material.Msg Msg)
  | UrlChange Navigation.Location
  | RegisterMsg Register.Types.Msg
  | LoginMsg Login.Types.Msg
  | ProfileMsg Profile.Types.Msg
  | ShowProfile
