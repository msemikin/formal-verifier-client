module Messages exposing (Msg(..))

import Navigation
import Material

import Register.Types as RegisterTypes

type Msg =
    Mdl (Material.Msg Msg)
  | RegisterMsg RegisterTypes.Msg
  | UrlChange Navigation.Location
